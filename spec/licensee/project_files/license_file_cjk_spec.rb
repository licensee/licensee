# frozen_string_literal: true

RSpec.describe Licensee::ProjectFiles::LicenseFile do
  let(:mulan) { Licensee::License.find('mulanpsl-2.0') }
  let(:file) { described_class.new(content, 'LICENSE') }
  let(:content) { mulan.content }

  it 'matches the bundled bilingual license exactly', :aggregate_failures do
    expect(file.matcher).to be_a(Licensee::Matchers::Exact)
    expect(file.license).to eq(mulan)
  end

  context 'with Chinese line wrapping removed (issue #1075)' do
    let(:content) { mulan.content.gsub(/(?<=\p{Han})\r?\n(?=\p{Han})/, '') }

    it 'matches despite different line wrapping', :aggregate_failures do
      expect(content).not_to eq(mulan.content)
      expect(file.content_normalized).to eq(mulan.content_normalized)
      expect(file.license).to eq(mulan)
    end

    context 'with different wrapping and filled-in attribution (issue #1075)' do
      let(:content) do
        mulan.content.gsub(/(?<=\p{Han})\r?\n(?=\p{Han})/, '')
             .gsub('[Year] [name of copyright holder]', '2026 ECOS Team <ecos-all@ict.ac.cn>')
             .gsub('[Software Name]', 'AnserCore')
      end

      it 'meets the similarity threshold and detects the license', :aggregate_failures do
        expect(mulan.similarity(file)).to be >= Licensee.confidence_threshold
        expect(file.matcher).to be_a(Licensee::Matchers::Dice)
        expect(file.license).to eq(mulan)
      end
    end
  end

  context 'with every Chinese character replaced at the same length' do
    let(:content) { mulan.content.gsub(/\p{Han}/, "\u9F98") }

    it 'rejects the altered license through both matchers', :aggregate_failures do
      expect(content.length).to eq(mulan.content.length)
      expect(Licensee::Matchers::Exact.new(file).match).to be_nil
      expect(Licensee::Matchers::Dice.new(file).match).to be_nil
      expect(file.license.key).to eq('other')
    end
  end

  context 'with Chinese characters removed' do
    let(:content) { mulan.content.gsub(/\p{Han}/, '') }

    it 'rejects the incomplete license through both matchers', :aggregate_failures do
      expect(Licensee::Matchers::Exact.new(file).match).to be_nil
      expect(Licensee::Matchers::Dice.new(file).match).to be_nil
      expect(file.license.key).to eq('other')
    end
  end

  context 'with Chinese characters reordered but the character set preserved' do
    let(:content) do
      characters = mulan.content.scan(/\p{Han}/)
      mulan.content.gsub(/\p{Han}/) { characters.pop }
    end

    it 'does not classify a wordset match as exact', :aggregate_failures do
      expect(file.wordset).to eq(mulan.wordset)
      expect(Licensee::Matchers::Exact.new(file).match).to be_nil
    end
  end
end
