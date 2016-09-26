RSpec.describe Licensee::Matchers::Cran do
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { "Package: test\nLicense: MIT + file LICENSE" }
  let(:file) { Licensee::Project::LicenseFile.new(content, 'project.gemspec') }
  subject { described_class.new(file) }

  it 'stores the file' do
    expect(subject.file).to eql(file)
  end

  it 'matches' do
    expect(subject.match).to eql(mit)
  end

  it 'is confident' do
    expect(subject.confidence).to eql(90)
  end
end
