# frozen_string_literal: true

RSpec.describe Licensee::Matchers::DistZilla do
  subject(:matcher) { described_class.new(file) }

  let(:mit) { Licensee::License.find('mit') }
  let(:content) { 'license = MIT' }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'dist.ini') }

  it 'stores the file' do
    expect(matcher.file).to eql(file)
  end

  it 'has confidence' do
    expect(matcher.confidence).to be(90)
  end

  it 'matches' do
    expect(matcher.match).to eql(mit)
  end

  {
    'spdx name'     => ['license = MIT', 'mit'],
    'non spdx name' => ['license = Mozilla_2_0', 'mpl-2.0'],
    'other license' => ['license = Foo', 'other']
  }.each do |description, license_declaration_and_key|
    context "with a #{description}" do
      let(:content) { license_declaration_and_key[0] }
      let(:license) { Licensee::License.find(license_declaration_and_key[1]) }

      it 'matches' do
        expect(matcher.match).to eql(license)
      end
    end
  end

  context 'with no license field' do
    let(:content) { 'foo = bar' }

    it 'returns nil' do
      expect(matcher.match).to be_nil
    end
  end
end
