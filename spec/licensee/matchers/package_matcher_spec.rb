RSpec.describe Licensee::Matchers::Package do
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { '' }
  let(:file) { Licensee::Project::LicenseFile.new(content, 'project.gemspec') }
  subject { described_class.new(file) }
  before { allow(subject).to receive(:license_property).and_return('mit') }

  it 'matches' do
    expect(subject.match).to eql(mit)
  end

  it 'has confidence' do
    expect(subject.confidence).to eql(90)
  end
end
