RSpec.describe Licensee::Matchers::Exact do
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { sub_copyright_info(mit.content) }
  let(:file) { Licensee::Project::LicenseFile.new(content, 'LICENSE.txt') }
  subject { described_class.new(file) }

  it 'stores the file' do
    expect(subject.file).to eql(file)
  end

  it 'matches' do
    expect(subject.match).to eql(mit)
  end

  it 'is confident' do
    expect(subject.confidence).to eql(100)
  end

  context 'with extra words added' do
    let(:content) { add_random_words(mit.content) }

    it "doesn't match" do
      expect(subject.match).to be_nil
    end
  end
end
