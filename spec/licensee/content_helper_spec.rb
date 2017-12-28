class ContentHelperTestHelper
  include Licensee::ContentHelper
  attr_accessor :content

  def initialize(content = nil)
    @content = content
  end
end

RSpec.describe Licensee::ContentHelper do
  let(:content) do
    <<-LICENSE.freeze.gsub(/^\s*/, '')
  # The MIT License
	=================

	Copyright 2016 Ben Balter
	*************************

  All rights reserved.

  The made
  * * * *
  up  license.
  -----------
LICENSE
  end
  subject { ContentHelperTestHelper.new(content) }
  let(:mit) { Licensee::License.find('mit') }

  it 'creates the wordset' do
    expect(subject.wordset).to eql(Set.new(%w[the made up license]))
  end

  it 'knows the length' do
    expect(subject.length).to eql(20)
  end

  context 'a very long license' do
    let(:content) { 'license' * 1000 }

    it 'returns the max delta' do
      expect(subject.max_delta).to eql(140)
    end
  end

  it 'knows the length delta' do
    expect(subject.length_delta(mit)).to eql(999)
    expect(subject.length_delta(subject)).to eql(0)
  end

  it 'knows the similarity' do
    expect(subject.similarity(mit)).to be_within(1).of(2)
    expect(subject.similarity(subject)).to eql(100.0)
  end

  it 'calculates the hash' do
    content_hash = '3c59634b9fae4396a76a978f3f6aa718ed790a9a'
    expect(subject.content_hash).to eql(content_hash)
  end

  it 'wraps' do
    content = Licensee::ContentHelper.wrap(mit.content, 40)
    lines = content.split("\n")
    expect(lines.first.length).to be <= 40
  end

  it 'formats percents' do
    percent = Licensee::ContentHelper.format_percent(12.3456789)
    expect(percent).to eql('12.35%')
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
      expect(normalized_content).to_not match '==='
      expect(normalized_content).to_not include '***'
      expect(normalized_content).to_not include '* *'
    end

    it 'strips formatting from the MPL' do
      license = Licensee::License.find('mpl-2.0')
      expect(license.content_normalized).to_not include('* *')
    end

    it 'wraps' do
      lines = mit.content_normalized(wrap: 40).split("\n")
      expect(lines.first.length).to be <= 40
    end

    it 'squeezes whitespace' do
      expect(normalized_content).to_not match '  '
    end

    it 'strips whitespace' do
      expect(normalized_content).to_not match(/\n/)
      expect(normalized_content).to_not match(/\t/)
    end

    it 'strips markdown headings' do
      expect(normalized_content).to_not match('#')
    end

    it 'strips all rights reserved' do
      expect(normalized_content).to_not match(/all rights reserved/i)
    end

    Licensee::License.all(hidden: true).each do |license|
      context license.name do
        let(:stripped_content) { subject.content_without_title_and_version }

        it 'strips the title' do
          regex = Licensee::ContentHelper::ALT_TITLE_REGEX[license.key]
          regex ||= /\A#{license.name_without_version}/i
          expect(license.content_normalized).to_not match(regex)
          expect(stripped_content).to_not match(regex)
        end

        it 'strips the version' do
          expect(license.content_normalized).to_not match(/\Aversion/i)
          expect(stripped_content).to_not match(/\Aversion/i)
        end

        it 'strips all rights reserved' do
          regex = /all rights reserved/i
          expect(license.content_normalized).to_not match(regex)
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

    context 'multiple copyrights' do
      let(:content) { "Copyright 2016 Ben Balter\nCopyright 2017 Bob\nFoo" }

      it 'strips multiple copyrights' do
        expect(normalized_content).to_not match('Ben')
        expect(normalized_content).to eql('foo')
      end
    end
  end

  context 'title regex' do
    let(:license) { Licensee::License.find('gpl-3.0') }

    %i[key title nickname name_without_version].each do |variation|
      context "a license #{variation}" do
        let(:license_variation) { license.send(variation) }
        let(:text) { license_variation }

        it 'matches' do
          expect(text).to match(described_class.title_regex)
        end

        context 'preceded by the' do
          let(:text) { "The #{license_variation} license" }

          it 'matches' do
            expect(text).to match(described_class.title_regex)
          end
        end

        context 'with parens' do
          let(:text) { "(#{license_variation})" }

          it 'matches' do
            expect(text).to match(described_class.title_regex)
          end
        end

        context 'with parens and a preceding the' do
          let(:text) { "(the #{license_variation} license)" }

          it 'matches' do
            expect(text).to match(described_class.title_regex)
          end
        end

        context 'with whitespace' do
          let(:text) { "     the #{license_variation} license" }

          it 'matches' do
            expect(text).to match(described_class.title_regex)
          end
        end

        context 'escaping' do
          let(:text) { 'gpl-3 0' }

          it 'escapes' do
            expect(text).to_not match(described_class.title_regex)
          end
        end

        context 'in the middle of a string' do
          let(:text) do
            "The project is not licensed under the #{license_variation} license"
          end

          it 'matches' do
            expect(text).to_not match(described_class.title_regex)
          end
        end
      end
    end
  end
end
