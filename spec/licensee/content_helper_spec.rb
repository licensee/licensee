class ContentHelperTestHelper
  include Licensee::ContentHelper
  attr_accessor :content

  def initialize(content = nil)
    @content = content
  end
end

RSpec.describe Licensee::ContentHelper do
  let(:content) do
    <<-EOS.freeze
The MIT License

Copyright 2016 Ben Balter

The made
up  license.
-----------
EOS
  end
  subject { ContentHelperTestHelper.new(content) }
  let(:mit) { Licensee::License.find('mit') }

  it 'creates the wordset' do
    expect(subject.wordset).to eql(Set.new(%w(the made up license)))
  end

  it 'knows the length' do
    expect(subject.length).to eql(20)
  end

  it 'knows the max delta' do
    expect(subject.max_delta).to eql(1)
  end

  it 'knows the length delta' do
    expect(subject.length_delta(mit)).to eql(1000)
    expect(subject.length_delta(subject)).to eql(0)
  end

  it 'knows the similarity' do
    expect(subject.similarity(mit)).to be_within(1).of(2)
    expect(subject.similarity(subject)).to eql(100.0)
  end

  it 'calculates the hash' do
    expect(subject.hash).to eql('3c59634b9fae4396a76a978f3f6aa718ed790a9a')
  end

  context 'normalizing' do
    let(:normalized_content) { subject.content_normalized }

    it 'strips copyright' do
      expect(normalized_content).to_not match 'Copyright'
      expect(normalized_content).to_not match 'Ben Balter'
    end

    it 'downcases' do
      expect(normalized_content).to_not match 'The'
      expect(normalized_content).to match 'the'
    end

    it 'strips HRs' do
      expect(normalized_content).to_not match '---'
    end

    it 'squeezes whitespace' do
      expect(normalized_content).to_not match '  '
    end

    it 'strips whitespace' do
      expect(normalized_content).to_not match(/\n/)
    end

    Licensee::License.all(hidden: true).each do |license|
      context license.name do
        let(:stripped_content) { subject.content_without_title_and_version }

        it 'strips the title' do
          regex = /\A#{license.name_without_version}/i
          expect(license.content_normalized).to_not match(regex)
          expect(stripped_content).to_not match(regex)
        end

        it 'strips the version' do
          expect(license.content_normalized).to_not match(/\Aversion/i)
          expect(stripped_content).to_not match(/\Aversion/i)
        end

        it 'strips the copyright' do
          expect(license.content_normalized).to_not match(/\Acopyright/i)
        end

        it 'strips the implementation instructions' do
          end_terms_regex = /END OF TERMS AND CONDITIONS/i
          expect(license.content_normalized).to_not match(end_terms_regex)
          expect(license.content_normalized).to_not match(/How to apply/i)
        end
      end
    end

    it 'strips the title' do
      expect(normalized_content).to_not match('MIT')
    end

    it 'normalize the content' do
      expect(normalized_content).to eql 'the made up license.'
    end

    context 'a title in parenthesis' do
      let(:content) { "(The MIT License)\n\nfoo" }

      it 'strips the title' do
        expect(normalized_content).to_not match('MIT')
        expect(normalized_content).to eql('foo')
      end
    end
  end
end
