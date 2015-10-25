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
        [Matchers::Copyright, Matchers::Exact, Matchers::Dice]
      end

      def wordset
        @wordset ||= create_word_set(content)
      end

      def attribution
        matches = /^#{Matchers::Copyright::REGEX}$/i.match(content)
        matches[0].strip if matches
      end

      def self.name_score(filename)
        return 1.0 if filename =~ /\A(un)?licen[sc]e\z/i
        return 0.9 if filename =~ /\A(un)?licen[sc]e\.(md|markdown|txt)\z/i
        return 0.8 if filename =~ /\Acopy(ing|right)(\.[^.]+)?\z/i
        return 0.7 if filename =~ /\A(un)?licen[sc]e\.[^.]+\z/i
        return 0.5 if filename =~ /licen[sc]e/i
        return 0.0
      end
    end

    class Readme < LicenseFile
      SCORES = {
        /\AREADME\z/i => 1.0,
        /\AREADME\.(md|markdown|txt)\z/i => 0.9
      }

      CONTENT_REGEX = /^#+ Licen[sc]e$(.*?)(?=#+|\z)/im

      def self.name_score(filename)
        SCORES.each do |pattern, score|
          return score if pattern =~ filename
        end
        return 0.0
      end

      def self.license_content(content)
        match = CONTENT_REGEX.match(content)
        match[1].strip if match
      end
    end

    class PackageInfo < File
      def possible_matchers
        case ::File.extname(filename)
        when ".gemspec"
          [Matchers::Gemspec]
        when ".json"
          [Matchers::NpmBower]
        else
          []
        end
      end

      def self.name_score(filename)
        return 1.0  if ::File.extname(filename) == ".gemspec"
        return 1.0  if filename == "package.json"
        return 0.75 if filename == "bower.json"
        return 0.0
      end
    end
  end
end
