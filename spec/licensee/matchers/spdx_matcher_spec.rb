# frozen_string_literal: true

RSpec.describe Licensee::Matchers::Spdx do
  subject(:matcher) { described_class.new(file) }

  let(:content) { 'PackageLicenseDeclared: MIT' }
  let(:file) do
    Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.spdx')
  end
  let(:mit) { Licensee::License.find('mit') }
  let(:other) { Licensee::License.find('other') }

  it 'matches' do
    expect(matcher.match).to eql(mit)
  end

  it 'has a confidence' do
    expect(matcher.confidence).to be(90)
  end

  context 'with no license field' do
    let(:content) { 'foo: bar' }

    it 'returns nil' do
      expect(matcher.match).to be_nil
    end
  end

  context 'with an unknown license' do
    let(:content) { 'PackageLicenseDeclared: xyz' }

    it 'returns other' do
      expect(matcher.match).to eql(other)
    end
  end

  context 'with a license expression' do
    let(:content) { 'PackageLicenseDeclared: (MIT OR Apache-2.0)' }

    it 'returns other' do
      expect(matcher.match).to eql(other)
    end
  end
end
