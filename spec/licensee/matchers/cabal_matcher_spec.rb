# frozen_string_literal: true

RSpec.describe Licensee::Matchers::Cabal do
  subject(:matcher) { described_class.new(file) }

  let(:content) { 'license: mit' }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.txt') }
  let(:mit) { Licensee::License.find('mit') }
  let(:no_license) { Licensee::License.find('no-license') }

  it 'matches' do
    expect(matcher.match).to eql(mit)
  end

  it 'has a confidence' do
    expect(matcher.confidence).to be(90)
  end

  {
    'whitespace'         => 'license : mit',
    'no whitespace'      => 'license:mit',
    'leading whitespace' => ' license:mit'
  }.each do |description, license_declaration|
    context "with a #{description} declaration" do
      let(:content) { license_declaration }

      it 'matches' do
        expect(matcher.match).to eql(mit)
      end
    end
  end

  context 'with a non-standard license format' do
    let(:content) { "license: #{cabal_license}" }

    context 'with GPL-3' do
      let(:cabal_license) { 'GPL-3' }

      it 'returns GPL-3.0' do
        expect(matcher.match).to eql(Licensee::License.find('GPL-3.0'))
      end
    end

    context 'with GPL-2' do
      let(:cabal_license) { 'GPL-2' }

      it 'returns GPL-2.0' do
        expect(matcher.match).to eql(Licensee::License.find('GPL-2.0'))
      end
    end

    context 'with LGPL-2.1' do
      let(:cabal_license) { 'LGPL-2.1' }

      it 'returns LGPL-2.1' do
        expect(matcher.match).to eql(Licensee::License.find('LGPL-2.1'))
      end
    end

    context 'with LGPL-3' do
      let(:cabal_license) { 'LGPL-3' }

      it 'returns LGPL-3.0' do
        expect(matcher.match).to eql(Licensee::License.find('LGPL-3.0'))
      end
    end

    context 'with AGPL-3' do
      let(:cabal_license) { 'AGPL-3' }

      it 'returns AGPL-3.0' do
        expect(matcher.match).to eql(Licensee::License.find('AGPL-3.0'))
      end
    end

    context 'with BSD2' do
      let(:cabal_license) { 'BSD2' }

      it 'returns BSD-2-Clause' do
        expect(matcher.match).to eql(Licensee::License.find('BSD-2-Clause'))
      end
    end

    context 'with BSD3' do
      let(:cabal_license) { 'BSD3' }

      it 'returns BSD-3-Clause' do
        expect(matcher.match).to eql(Licensee::License.find('BSD-3-Clause'))
      end
    end

    context 'with MIT' do
      let(:cabal_license) { 'MIT' }

      it 'returns MIT' do
        expect(matcher.match).to eql(Licensee::License.find('MIT'))
      end
    end

    context 'with ISC' do
      let(:cabal_license) { 'ISC' }

      it 'returns ISC' do
        expect(matcher.match).to eql(Licensee::License.find('ISC'))
      end
    end

    context 'with MPL-2.0' do
      let(:cabal_license) { 'MPL-2.0' }

      it 'returns MPL-2.0' do
        expect(matcher.match).to eql(Licensee::License.find('MPL-2.0'))
      end
    end

    context 'with Apache-2.0' do
      let(:cabal_license) { 'Apache-2.0' }

      it 'returns Apache-2.0' do
        expect(matcher.match).to eql(Licensee::License.find('Apache-2.0'))
      end
    end
  end

  context 'with no license field' do
    let(:content) { 'foo: bar' }

    it 'returns nil' do
      expect(matcher.match).to be_nil
    end
  end

  context 'with an unknown license' do
    let(:content) { 'license: foo' }

    it 'returns other' do
      expect(matcher.match).to eql(Licensee::License.find('other'))
    end
  end
end
