class Licensee
  class CopyrightMatcher < Matcher

    REGEX = /^(©|\(c\)|Copyright) \d{4}(.*)\n?$/i

    def no_license
      @no_license ||= Licensee::Licenses.find("no-license")
    end

    def match
      no_license if file.content_normalized =~ REGEX
    end

    def confidence
      100
    end
  end
end
