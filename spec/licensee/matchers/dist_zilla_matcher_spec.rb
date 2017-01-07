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
end
