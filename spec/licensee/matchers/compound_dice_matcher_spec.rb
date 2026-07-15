# frozen_string_literal: true

RSpec.describe Licensee::Matchers::CompoundDice do
  subject(:matcher) { described_class.new(file) }

  def mit     = Licensee::License.find('mit')
  def apache  = Licensee::License.find('apache-2.0')
  def bsd3    = Licensee::License.find('bsd-3-clause')

  let(:mit_content)    { sub_copyright_info(mit) }
  let(:apache_content) { sub_copyright_info(apache) }
  let(:bsd3_content)   { sub_copyright_info(bsd3) }

  # ── Positive: compound MIT + Apache ──────────────────────────────────────

  context 'with a compound MIT + Apache-2.0 file' do
    let(:content) { "#{mit_content}\n\n#{apache_content}" }
    let(:file)    { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE') }

    it 'returns a match' do
      expect(matcher.match).not_to be_nil
    end

    it 'detects Apache-2.0 as the top compound match' do
      top_license, = matcher.compound_matches.first
      expect(top_license).to eql(apache)
    end

    it 'detects MIT as a compound match' do
      detected_licenses = matcher.compound_matches.map(&:first)
      expect(detected_licenses).to include(mit)
    end

    it 'detects Apache-2.0 as a compound match' do
      detected_licenses = matcher.compound_matches.map(&:first)
      expect(detected_licenses).to include(apache)
    end

    it 'detects both with >= confidence threshold' do
      expect(matcher.compound_matches.map(&:last)).to all(be >= Licensee.confidence_threshold)
    end

    it 'reports compound_dice as the matcher name' do
      expect(matcher.name).to eq(:compound_dice)
    end

    it 'is not matched by the standard Dice matcher' do
      dice = Licensee::Matchers::Dice.new(file)
      expect(dice.match).to be_nil
    end
  end

  # ── Positive: compound MIT + BSD-3-Clause ────────────────────────────────

  context 'with a compound MIT + BSD-3-Clause file' do
    let(:content) { "#{mit_content}\n\n#{bsd3_content}" }
    let(:file)    { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE') }

    it 'returns a match' do
      expect(matcher.match).not_to be_nil
    end

    it 'detects MIT as a compound match' do
      detected_licenses = matcher.compound_matches.map(&:first)
      expect(detected_licenses).to include(mit)
    end

    it 'detects BSD-3-Clause as a compound match' do
      detected_licenses = matcher.compound_matches.map(&:first)
      expect(detected_licenses).to include(bsd3)
    end

    it 'detects both with >= confidence threshold' do
      expect(matcher.compound_matches.map(&:last)).to all(be >= Licensee.confidence_threshold)
    end
  end

  # ── Positive: LicenseFile#compound_licenses convenience method ───────────

  context 'with a compound MIT + BSD-3-Clause file via LicenseFile' do
    let(:content) { "#{mit_content}\n\n#{bsd3_content}" }
    let(:file)    { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE') }

    it 'exposes compound_licenses on the LicenseFile' do
      expect(file.compound_licenses).not_to be_empty
    end

    it 'includes MIT via compound_licenses' do
      keys = file.compound_licenses.map { |l, _| l.key }
      expect(keys).to include('mit')
    end

    it 'includes bsd-3-clause via compound_licenses' do
      keys = file.compound_licenses.map { |l, _| l.key }
      expect(keys).to include('bsd-3-clause')
    end
  end

  # ── Negative: single-license file ────────────────────────────────────────

  context 'with a plain MIT file' do
    let(:file) { Licensee::ProjectFiles::LicenseFile.new(mit_content, 'LICENSE') }

    it 'does not run compound detection (Dice or Exact already matched)' do
      # Standard matchers (Exact, Dice) handle single-license files; compound_dice
      # should never be reached in the possible_matchers chain.
      expect(file.matcher).to be_a(Licensee::Matchers::Matcher)
    end

    it 'is matched by a standard matcher, not CompoundDice' do
      expect(file.matcher).not_to be_a(described_class)
    end

    it 'does not return compound matches when called directly' do
      # A single-license file spans the whole window, so the coverage guard
      # suppresses the match and compound detection returns nothing.
      detected_licenses = matcher.compound_matches.map(&:first)
      expect(detected_licenses).to be_empty
    end
  end

  # ── Negative: random non-license text ────────────────────────────────────

  context 'with random non-license text' do
    let(:content) do
      'Hello world. The quick brown fox jumped over the lazy dog. ' \
        'More random sentences without any license vocabulary here.'
    end
    let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE') }

    it 'returns no match' do
      expect(matcher.match).to be_nil
    end

    it 'returns empty compound_matches' do
      expect(matcher.compound_matches).to be_empty
    end

    it 'returns 0 confidence' do
      expect(matcher.confidence).to eq(0)
    end
  end

  # ── Negative: empty content ───────────────────────────────────────────────

  context 'with empty content' do
    let(:file) { Licensee::ProjectFiles::LicenseFile.new('', 'LICENSE') }

    it 'returns no match' do
      expect(matcher.match).to be_nil
    end

    it 'returns empty compound_matches' do
      expect(matcher.compound_matches).to be_empty
    end
  end
end
