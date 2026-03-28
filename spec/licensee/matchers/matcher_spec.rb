# frozen_string_literal: true

class MatcherSpecFixture < Licensee::Matchers::Matcher
  def confidence
    0
  end
end

RSpec.describe Licensee::Matchers::Matcher do
  subject(:matcher) { described_class.new(file) }

  let(:mit) { Licensee::License.find('mit') }
  let(:content) { sub_copyright_info(mit) }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.txt') }

  it 'stores the file' do
    expect(matcher.file).to eql(file)
  end

  it 'returns its name' do
    expect(matcher.name).to be(:matcher)
  end

  context 'when calling abstract methods on the base class' do
    it 'raises NotImplementedError for #match' do
      expect { matcher.match }.to raise_error(NotImplementedError, /Matcher#match/)
    end

    it 'raises NotImplementedError for #confidence' do
      expect { matcher.confidence }.to raise_error(NotImplementedError, /Matcher#confidence/)
    end
  end

  context 'when calling #to_h' do
    subject { MatcherSpecFixture.new(file) }

    let(:hash) { subject.to_h }
    let(:expected) do
      {
        confidence: 0,
        name:       :matcherspecfixture
      }
    end

    it 'converts to a hash' do
      expect(hash).to eql(expected)
    end
  end
end
