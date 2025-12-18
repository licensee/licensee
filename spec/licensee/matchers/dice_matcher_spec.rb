# frozen_string_literal: true

RSpec.describe Licensee::Matchers::Dice do
  subject { described_class.new(file) }

  def mit = Licensee::License.find('mit')
  def gpl = Licensee::License.find('gpl-3.0')
  def agpl = Licensee::License.find('agpl-3.0')
  def lgpl = Licensee::License.find('lgpl-2.1')
  def cc_by = Licensee::License.find('cc-by-4.0')
  def cc_by_sa = Licensee::License.find('cc-by-sa-4.0')

  def expected_top_matches
    [
      [gpl, 100.0],
      [agpl, 94.56967213114754],
      [lgpl, 26.821370750134918]
    ]
  end

  let(:content) { sub_copyright_info(gpl) }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.txt') }

  it 'stores the file' do
    expect(subject.file).to eql(file)
  end

  it 'matches' do
    expect(subject.match).to eql(gpl)
  end

  it 'sorts licenses by similarity' do
    expect(subject.matches_by_similarity.first(3)).to eql(expected_top_matches)
  end

  it 'returns the match confidence' do
    expect(subject.confidence).to eq(100.0)
  end

  context 'without a match' do
    let(:content) { 'Not really a license' }

    it "doesn't match" do
      expect(subject).to have_attributes(match: nil, matches: be_empty, confidence: 0)
    end
  end

  context 'with stacked licenses' do
    let(:content) do
      "#{sub_copyright_info(mit)}\n\n#{sub_copyright_info(gpl)}"
    end

    it "doesn't match" do
      detection = [be_detected_as(gpl).matches?(content), subject.match, subject.matches.empty?, subject.confidence]
      expect(detection).to eql([false, nil, true, 0])
    end
  end

  context 'with a CC false positive' do
    context 'with CC-BY' do
      let(:content) { cc_by.content }

      it 'matches' do
        expect(content).to be_detected_as(cc_by)
      end
    end

    context 'with CC-ND' do
      let(:content) do
        File.read(File.expand_path('LICENSE', fixture_path('cc-by-nd')))
      end

      it "doesn't match" do
        detection = [be_detected_as(cc_by).matches?(content), be_detected_as(cc_by_sa).matches?(content),
                     subject.match, subject.matches.empty?, subject.confidence]
        expect(detection).to eql([false, false, nil, true, 0])
      end
    end
  end
end
