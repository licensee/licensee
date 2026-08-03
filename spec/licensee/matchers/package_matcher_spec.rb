# frozen_string_literal: true

RSpec.describe Licensee::Matchers::Package do
  let(:file) do
    Licensee::ProjectFiles::LicenseFile.new('', 'project.gemspec')
  end
  let(:license_property) { 'mit' }
  let(:matcher) { matcher_class.new(file, license_property) }

  def matcher_class
    Class.new(described_class) do
      attr_reader :license_property

      def initialize(file, license_property)
        super(file)
        @license_property = license_property
      end
    end
  end

  it 'matches' do
    expect(matcher.match).to eql(Licensee::License.find('mit'))
  end

  it 'has confidence' do
    expect(matcher.confidence).to be(90)
  end

  context 'with a nil license property' do
    let(:license_property) { nil }

    it 'matches to nil' do
      expect(matcher.match).to be_nil
    end
  end

  context 'with an empty license property' do
    let(:license_property) { '' }

    it 'matches to nil' do
      expect(matcher.match).to be_nil
    end
  end

  context 'with an unmatched license proprerty' do
    let(:license_property) { 'foo' }

    it 'matches to other' do
      expect(matcher.match).to eql(Licensee::License.find('other'))
    end
  end

  context 'with an -or-later SPDX suffix' do
    let(:license_property) { 'lgpl-3.0-or-later' }

    it 'matches the base license' do
      expect(matcher.match).to eql(Licensee::License.find('lgpl-3.0'))
    end
  end

  context 'with an -only SPDX suffix' do
    let(:license_property) { 'lgpl-3.0-only' }

    it 'matches the base license' do
      expect(matcher.match).to eql(Licensee::License.find('lgpl-3.0'))
    end
  end

  context 'when calling abstract methods on the base class' do
    let(:base_matcher) { described_class.new(file) }

    it 'raises NotImplementedError for #license_property' do
      expect { base_matcher.send(:license_property) }.to raise_error(NotImplementedError, /Package#license_property/)
    end
  end

  describe '#spdx_expression_licenses' do
    context 'with a plain single license key' do
      let(:license_property) { 'mit' }

      it 'returns nil (not a compound expression)' do
        expect(matcher.spdx_expression_licenses).to be_nil
      end
    end

    context 'with a nil license property' do
      let(:license_property) { nil }

      it 'returns nil' do
        expect(matcher.spdx_expression_licenses).to be_nil
      end
    end

    context 'with an "MIT OR Apache-2.0" expression' do
      let(:license_property) { 'MIT OR Apache-2.0' }

      it 'does not include the OR operator as a license' do
        expect(matcher.spdx_expression_licenses.size).to eq(2)
      end

      it 'includes MIT' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('mit'))
      end

      it 'includes Apache-2.0' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('apache-2.0'))
      end
    end

    context 'with an "MIT AND Apache-2.0" expression' do
      let(:license_property) { 'MIT AND Apache-2.0' }

      it 'includes MIT' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('mit'))
      end

      it 'includes Apache-2.0' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('apache-2.0'))
      end
    end

    context 'with a compound expression containing an unknown identifier' do
      let(:license_property) { 'UnknownFoo OR MIT' }

      it 'returns other for the unknown identifier' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('other'))
      end

      it 'returns MIT for the known identifier' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('mit'))
      end
    end

    context 'with a compound expression where all identifiers are unknown' do
      let(:license_property) { 'UnknownFoo OR AnotherUnknown' }

      it 'returns other for all tokens' do
        result = matcher.spdx_expression_licenses
        expect(result).to all(eq(Licensee::License.find('other')))
      end
    end

    context 'with -or-later suffix tokens in compound expression' do
      let(:license_property) { 'LGPL-2.1-or-later OR GPL-3.0-or-later' }

      it 'strips -or-later and returns LGPL-2.1' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('lgpl-2.1'))
      end

      it 'strips -or-later and returns GPL-3.0' do
        expect(matcher.spdx_expression_licenses).to include(Licensee::License.find('gpl-3.0'))
      end
    end
  end
end
