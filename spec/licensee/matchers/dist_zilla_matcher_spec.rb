RSpec.describe Licensee::Matchers::DistZilla do
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { 'license = MIT' }
  let(:file) { Licensee::Project::LicenseFile.new(content, 'dist.ini') }
  subject { described_class.new(file) }

  it 'stores the file' do
    expect(subject.file).to eql(file)
  end

  it 'has confidence' do
    expect(subject.confidence).to eql(90)
  end

  it 'matches' do
    expect(subject.match).to eql(mit)
  end

  {
    'spdx name'     => ["license = MIT", 'mit'],
    'non spdx name' => ['license = Mozilla_2_0', 'mpl-2.0'],
  }.each do |description, license_declaration_and_key|
    context "with a #{description}" do
      let(:content) { license_declaration_and_key[0] }
      let(:license) { Licensee::License.find(license_declaration_and_key[1]) }

      it 'matches' do
        expect(subject.match).to eql(license)
      end
    end
  end

end
