RSpec.describe Licensee::Matchers::Dice do
  let(:mit) { Licensee::License.find('mit') }
  let(:gpl) { Licensee::License.find('gpl-3.0') }
  let(:agpl) { Licensee::License.find('agpl-3.0') }
  let(:cc_by) { Licensee::License.find('cc-by-4.0') }
  let(:cc_by_sa) { Licensee::License.find('cc-by-sa-4.0') }
  let(:content) { sub_copyright_info(gpl) }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.txt') }
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
    expect(subject.licenses_by_similiarity[1]).to eql([agpl, 86.66032027067445])
  end

  it 'returns a list of licenses above the confidence threshold' do
    expect(subject.licenses_by_similiarity[0]).to eql([gpl, 100.0])
    expect(subject.licenses_by_similiarity[1]).to eql([agpl, 86.66032027067445])
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

  context 'stacked licenses' do
    let(:content) do
      sub_copyright_info(mit) + "\n\n" + sub_copyright_info(gpl)
    end

    it "doesn't match" do
      expect(content).to_not be_detected_as(gpl)
      expect(subject.match).to eql(nil)
      expect(subject.matches).to be_empty
      expect(subject.confidence).to eql(0)
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

      it "doesn't match" do
        expect(content).to_not be_detected_as(cc_by)
        expect(content).to_not be_detected_as(cc_by_sa)
        expect(subject.match).to be_nil
        expect(subject.matches).to be_empty
        expect(subject.confidence).to eql(0)
      end
    end
  end

  context 'confidence similarity match' do
    module Licensee
      module ContentHelper
        alias max_delta_original max_delta
        alias max_delta calculate_max_delta
        public :max_delta
      end
    end

    Licensee.licenses(hidden: true).each do |license|
      next if license.pseudo_license?
      context "the #{license.key} license" do
        let(:content) { license.content }

        nearest =
          Licensee
          .licenses(hidden: true)
          .reject { |other| other.pseudo_license? || other.key == license.key }
          .collect { |other| [other, license.similarity(other)] }
          .max_by { |other_similarity| other_similarity[1] }
        next if nearest[1] < 50

        it "matches #{nearest[0].key}" do
          Licensee.confidence_threshold = nearest[1].floor

          matcher = Licensee::Matchers::Dice.new(file)
          similars = matcher.licenses_by_similiarity.map { |s| s[0] }

          expect(similars).to include nearest[0]
          Licensee.confidence_threshold = Licensee::CONFIDENCE_THRESHOLD
        end
      end
    end
  end
end
