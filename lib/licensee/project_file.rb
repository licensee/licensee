# encoding=utf-8
class Licensee
  class Project
    private
    class File
      attr_reader :content, :filename

      def initialize(content, filename = nil)
        @content = content
        @content.force_encoding(Encoding::UTF_8)
        @filename = filename
      end

      def matcher
        @matcher ||= possible_matchers.map { |m| m.new(self) }.find { |m| m.match }
      end

      # Returns the percent confident with the match
      def confidence
        matcher && matcher.confidence
      end

      def license
        matcher && matcher.match
      end

      alias_method :match, :license
      alias_method :path, :filename
    end

    public
    class LicenseFile < File
      include Licensee::ContentHelper

      def possible_matchers
        [Matcher::Copyright, Matcher::Exact, Matcher::Dice]
      end

      def wordset
        @wordset ||= create_word_set(content)
      end

      def attribution
        matches = /^#{Matcher::Copyright::REGEX}$/i.match(content)
        matches[0].strip if matches
      end
    end

    public
    class PackageInfo < File
      def possible_matchers
        [Matcher::Gemspec, Matcher::NpmBower]
      end
    end
  end
end
