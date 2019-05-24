# frozen_string_literal: true

RSpec.describe Licensee::Matchers::Matcher do
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { sub_copyright_info(mit) }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.txt') }
  subject { described_class.new(file) }

  it 'stores the file' do
    expect(subject.file).to eql(file)
  end

  it 'returns its name' do
    expect(subject.name).to eql(:matcher)
  end

  context 'to_h' do
    class MatcherSpecFixture < Licensee::Matchers::Matcher
      def confidence
        0
      end
    end

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
