require 'set'
require 'digest'

module Licensee
  module ContentHelper
    DIGEST = Digest::SHA1
    END_OF_TERMS_REGEX = /^[\s#*_]*end of terms and conditions\s*$/i
    HR_REGEX = /[=\-\*][=\-\*\s]{3,}/
    ALT_TITLE_REGEX = License::ALT_TITLE_REGEX
    ALL_RIGHTS_RESERVED_REGEX = /\Aall rights reserved\.?$/i
    WHITESPACE_REGEX = /\s+/
    MARKDOWN_HEADING_REGEX = /\A\s*#+/
    VERSION_REGEX = /\Aversion.*$/i
    MARKUP_REGEX = /[#_*=~\[\]()`|>]+/

    # A set of each word in the license, without duplicates
    def wordset
      @wordset ||= if content_normalized
        content_normalized.scan(/(?:\w(?:'s|(?<=s)')?)+/).to_set
      end
    end

    # Number of characteres in the normalized content
    def length
      return 0 unless content_normalized
      content_normalized.length
    end

    # Number of characters that could be added/removed to still be
    # considered a potential match
    def max_delta
      @max_delta ||= (length * Licensee.inverse_confidence_threshold).to_i
    end

    # Given another license or project file, calculates the difference in length
    def length_delta(other)
      (length - other.length).abs
    end

    # Given another license or project file, calculates the similarity
    # as a percentage of words in common
    def similarity(other)
      overlap = (wordset & other.wordset).size
      total = wordset.size + other.wordset.size
      100.0 * (overlap * 2.0 / total)
    end

    # SHA1 of the normalized content
    def content_hash
      @content_hash ||= DIGEST.hexdigest content_normalized
    end

    # Content with the title and version removed
    # The first time should normally be the attribution line
    # Used to dry up `content_normalized` but we need the case sensitive
    # content with attribution first to detect attribuion in LicenseFile
    def content_without_title_and_version
      @content_without_title_and_version ||= begin
        string = content.strip
        string = strip_markdown_headings(string)
        string = strip_hrs(string)
        string = strip_title(string) while string =~ ContentHelper.title_regex
        strip_version(string).strip
      end
    end

    # Content without title, version, copyright, whitespace, or insturctions
    #
    # wrap - Optional width to wrap the content
    #
    # Returns a string
    def content_normalized(wrap: nil)
      return unless content
      @content_normalized ||= begin
        string = content_without_title_and_version.downcase
        while string =~ Matchers::Copyright::REGEX
          string = strip_copyright(string)
        end
        string = strip_all_rights_reserved(string)
        string, _partition, _instructions = string.partition(END_OF_TERMS_REGEX)
        string = strip_markup(string)
        string = normalize_quotes(string)
        strip_whitespace(string)
      end

      if wrap.nil?
        @content_normalized
      else
        Licensee::ContentHelper.wrap(@content_normalized, wrap)
      end
    end

    # Wrap text to the given line length
    def self.wrap(text, line_width = 80)
      return if text.nil?
      text = text.clone
      text.gsub!(/([^\n])\n([^\n])/, '\1 \2')

      text = text.split("\n").collect do |line|
        if line.length > line_width
          line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
        else
          line
        end
      end * "\n"

      text.strip
    end

    def self.format_percent(float)
      "#{format('%.2f', float)}%"
    end

    def self.title_regex
      licenses = Licensee::License.all(hidden: true, psuedo: false)
      titles = licenses.map(&:title_regex)

      # Title regex must include the version to support matching within
      # families, but for sake of normalization, we can be less strict
      without_versions = licenses.map do |license|
        next if license.title == license.name_without_version
        Regexp.new Regexp.escape(license.name_without_version), 'i'
      end
      titles.concat(without_versions.compact)

      /\A\s*\(?(the )?#{Regexp.union titles}.*$/i
    end

    private

    def strip_title(string)
      strip(string, ContentHelper.title_regex)
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

    def strip(string, regex)
      string.gsub(regex, ' ').squeeze(' ').strip
    end

    # Replace all single quotes with double quotes
    # Single versus double quotes don't alter the meaning, and it's easier to
    # strip double quotes if we still want to allow possessives
    def normalize_quotes(string)
      string.gsub(/\s'([\w -]*?\w)'/, ' "\1"')
    end
  end
end
