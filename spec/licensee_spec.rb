# frozen_string_literal: true

RSpec.describe Licensee do
  let(:project_path) { fixture_path('mit') }
  let(:license_path) { fixture_path('mit/LICENSE.txt') }
  let(:mit_license) { Licensee::License.find('mit') }
  let(:hidden_license_count) { 49 }

  it 'exposes licenses' do
    licenses = described_class.licenses
    hidden_licenses = described_class.licenses(hidden: true).count

    expect([licenses.is_a?(Array), hidden_licenses, licenses.first.is_a?(Licensee::License)]).to eql(
      [true, hidden_license_count, true]
    )
  end

  it "detects a project's license" do
    expect(described_class.license(project_path)).to eql(mit_license)
  end

  it "detect a file's license" do
    expect(described_class.license(license_path)).to eql(mit_license)
  end

  describe '.project' do
    subject { described_class.project(project_path) }

    it 'inits a project' do
      expect(subject).to be_a(Licensee::Projects::Project)
    end

    context 'when given a GitHub repository' do
      let(:project_path) { 'https://github.com/benbalter/licensee' }

      it 'creates a GitHubProject' do
        expect(subject).to be_a(Licensee::Projects::GitHubProject)
      end
    end
  end

  context 'when using the confidence threshold' do
    it 'exposes the confidence threshold' do
      expect(described_class.confidence_threshold).to be(98)
    end

    it 'exposes the inverse of the confidence threshold' do
      expect(described_class.inverse_confidence_threshold).to eq(0.02)
    end

    context 'when user overridden' do
      before { described_class.confidence_threshold = 50 }

      after { described_class.confidence_threshold = nil }

      it 'lets the user override the confidence threshold' do
        expect(described_class.confidence_threshold).to be(50)
      end

      it 'resets inverse confidence threshold when confidence threshold changes' do
        before_reset = described_class.inverse_confidence_threshold
        described_class.confidence_threshold = Licensee::CONFIDENCE_THRESHOLD
        after_reset = described_class.inverse_confidence_threshold

        expect([before_reset, after_reset]).to eql([0.5, 0.02])
      end
    end
  end
end
