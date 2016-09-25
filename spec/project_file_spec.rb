RSpec.describe Licensee::Project::File do
  let(:filename) { 'LICENSE.txt' }
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { mit.content }
  let(:possible_matchers) { [Licensee::Matchers::Exact] }

  subject { described_class.new(content, filename) }
  before do
    allow(subject).to receive(:possible_matchers).and_return(possible_matchers)
  end
  before { allow(subject).to receive(:length).and_return(mit.length) }
  before { allow(subject).to receive(:wordset).and_return(mit.wordset) }

  it 'stores the content' do
    expect(subject.content).to eql(content)
  end

  it 'stores the filename' do
    expect(subject.filename).to eql(filename)
  end

  it 'returns the matcher' do
    expect(subject.matcher).to be_a(Licensee::Matchers::Exact)
  end

  it 'returns the confidence' do
    expect(subject.confidence).to eql(100)
  end

  it 'returns the license' do
    expect(subject.license).to eql(mit)
  end
end
