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
end
