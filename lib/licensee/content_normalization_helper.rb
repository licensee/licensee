module Licensee
  class ContentNormalizationHelper
    def initialize(string)
      @string = string
    end

    def content_normalized
      @content_normalized ||= begin

      end
    end

    private

    attr_reader :string

    def strip(regex)
      string = string.gsub(regex, ' ').squeeze(' ').strip
    end

    def strip_title
      strip(ContentHelper.title_regex)
    end

    def strip_version(string)
      strip(string, VERSION_REGEX)
    end

    def strip_copyright(string)
      strip(string, Matchers::Copyright::REGEX)
    end

    # Strip HRs from MPL
    def strip_hrs(string)
      strip(string, HR_REGEX)
    end

    # Strip leading #s from the document
    def strip_markdown_headings(string)
      strip(string, MARKDOWN_HEADING_REGEX)
    end

    def strip_whitespace(string)
      strip(string, WHITESPACE_REGEX)
    end

    def strip_all_rights_reserved(string)
      strip(string, ALL_RIGHTS_RESERVED_REGEX)
    end

    def strip_markup(string)
      strip(string, MARKUP_REGEX)
    end

    def strip_url(string)
      strip(string, URL_REGEX)
    end

    def strip_borders(string)
      string.gsub(/^\*(.*?)\*$/, '\1')
    end



    def normalize_dashes(string)
      string.gsub(/[—–-]+/, '-')
    end

    def normalize_quotes(string)
      string = string.gsub(/[“”]+(?!s\s)/, '"')
      string.gsub(/’/, "'")
    end

    def normalize_spelling(string)
      regex = /\b#{Regexp.union(VARIETAL_WORDS.keys)}\b/
      string.gsub(regex, VARIETAL_WORDS)
    end

    def normalize_copyright(string)
      string.gsub(/(?:copyright\ )?#{Matchers::Copyright::COPYRIGHT_SYMBOLS}/, 'copyright')
    end

    def normalize_bullets(string)
      string.gsub(BULLET_REGEX, "\n\n* ").gsub(/\)\s+\(/, ')(')
    end

    def normalize_ampersands(string)
      string.gsub("&", "and")
    end
  end
end
