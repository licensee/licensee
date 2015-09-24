class Licensee
  class ProjectFile
    include Licensee::ContentHelper

    attr_reader :content, :filename

    def initialize(content, filename = nil)
      @content = content
      @content.force_encoding(Encoding::UTF_8)
      @filename = filename
    end

    def wordset
      @wordset ||= create_word_set(content)
    end

    # Returns an Licensee::License instance of the matches license
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
  end

  class ProjectLicense < ProjectFile
    def possible_matchers
      [Matcher::Copyright, Matcher::Exact, Matcher::Dice]
    end

    def attribution
      matches = /^#{Matcher::Copyright::REGEX}$/i.match(content)
      matches[0].strip if matches
    end
  end

  class ProjectPackage < ProjectFile
    def possible_matchers
      [Matcher::Gemspec, Matcher::NpmBower]
    end
  end
end
