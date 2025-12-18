# frozen_string_literal: true

RSpec.describe Licensee::Matchers::Dice do
  subject { described_class.new(file) }

  let(:mit) { Licensee::License.find('mit') }
  let(:gpl) { Licensee::License.find('gpl-3.0') }
  let(:agpl) { Licensee::License.find('agpl-3.0') }
  let(:lgpl) { Licensee::License.find('lgpl-2.1') }
  let(:cc_by) { Licensee::License.find('cc-by-4.0') }
  let(:cc_by_sa) { Licensee::License.find('cc-by-sa-4.0') }
  let(:content) { sub_copyright_info(gpl) }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.txt') }
  let(:expected_top_matches) do
    [
      [gpl, 100.0],
      [agpl, 94.56967213114754],
      [lgpl, 26.821370750134918]
    ]
  end

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

  context 'stacked licenses' do
    let(:content) do
      "#{sub_copyright_info(mit)}\n\n#{sub_copyright_info(gpl)}"
    end
    let(:detection) do
      [
        be_detected_as(gpl).matches?(content),
        subject.match,
        subject.matches.empty?,
        subject.confidence
      ]
    end

    it "doesn't match" do
      expect(detection).to eql([false, nil, true, 0])
    end
  end

  context 'CC false positive' do
    context 'CC-BY' do
      let(:content) { cc_by.content }

      it 'matches' do
        expect(content).to be_detected_as(cc_by)
      end
    end

    context 'CC-ND' do
      let(:project_path) { fixture_path('cc-by-nd') }
      let(:license_path) { File.expand_path('LICENSE', project_path) }
      let(:content) { File.read(license_path) }
      let(:detection) do
        [
          be_detected_as(cc_by).matches?(content),
          be_detected_as(cc_by_sa).matches?(content),
          subject.match,
          subject.matches.empty?,
          subject.confidence
        ]
      end

      it "doesn't match" do
        expect(detection).to eql([false, false, nil, true, 0])
      end
    end
  end
end
