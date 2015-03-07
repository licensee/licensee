class Licensee
  class CopyrightMatcher < Matcher

    REGEX = /\A(Copyright )?(©|\(c\)) \d{4}(.*)\n?\z/i

    def match
      no_license if file.content_normalized =~ REGEX
    end

    def confidence
      100
    end

    private

    def no_license
      @no_license ||= Licensee::Licenses.find("no-license")
    end
  end
end
