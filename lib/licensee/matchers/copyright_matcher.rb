# encoding=utf-8
class Licensee
  class CopyrightMatcher < Matcher

    REGEX = /\s*Copyright (©|\(c\)|\xC2\xA9)? ?(\d{4}|\[year\])(.*)?\s*/i

    def match
      # Note: must use content, and not content_normalized here
      no_license if file.content.strip =~ /\A#{REGEX}\z/i
    rescue
      nil
    end

    def confidence
      100
    end

    private

    def no_license
      @no_license ||= Licensee::License.find("no-license")
    end
  end
end
