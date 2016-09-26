RSpec.describe Licensee::Matchers::Dice do
  let(:gpl) { Licensee::License.find('gpl-3.0') }
  let(:agpl) { Licensee::License.find('agpl-3.0') }
  let(:content) { sub_copyright_info(gpl.content) }
  let(:file) { Licensee::Project::LicenseFile.new(content, 'LICENSE.txt') }
  subject { described_class.new(file) }

  it 'stores the file' do
    expect(subject.file).to eql(file)
  end

  it 'matches' do
    expect(subject.match).to eql(gpl)
  end

  it 'builds a list of potential licenses' do
    expect(subject.potential_licenses).to eql([agpl, gpl])
  end

  it 'sorts licenses by similarity' do
    expect(subject.licenses_by_similiarity[0]).to eql([gpl, 100.0])
    expect(subject.licenses_by_similiarity[1]).to eql([agpl, 94.06571848945562])
  end

  it 'returns a list of licenses above the confidence threshold' do
    expect(subject.licenses_by_similiarity[0]).to eql([gpl, 100.0])
    expect(subject.licenses_by_similiarity[1]).to eql([agpl, 94.06571848945562])
  end

  it 'returns the match confidence' do
    expect(subject.confidence).to eql(100.0)
  end

  context 'without a match' do
    let(:content) { 'Not really a license' }

    it "doesn't match" do
      expect(subject.match).to eql(nil)
      expect(subject.matches).to be_empty
      expect(subject.confidence).to eql(0)
    end
  end
end
