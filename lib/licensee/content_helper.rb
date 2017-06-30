require 'set'
require 'digest'

module Licensee
  module ContentHelper
    DIGEST = Digest::SHA1
    END_OF_TERMS_REGEX = /^\s*end of terms and conditions\s*$/i
    HR_REGEX = /^\s*[=\-\*\s]{4,}/
    ALT_TITLE_REGEX = {
      'bsd-2-clause'       => /bsd 2-clause( \"simplified\")? license/i,
      'bsd-3-clause'       => /bsd 3-clause( \"new\" or \"revised\")? license/i,
      'bsd-3-clause-clear' => /bsd 3-clause( clear)? license/i
    }.freeze

    # A set of each word in the license, without duplicates
    def wordset
      @wordset ||= if content_normalized
        content_normalized.scan(/[\w']+/).to_set
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
        string = strip_title(string) while string =~ title_regex
        strip_version(string).strip
      end
    end

    # Content without title, version, copyright, whitespace, or insturctions
    def content_normalized
      return unless content
      @content_normalized ||= begin
        string = content_without_title_and_version.downcase
        while string =~ Matchers::Copyright::REGEX
          string = strip_copyright(string)
        end
        string, _partition, _instructions = string.partition(END_OF_TERMS_REGEX)
        strip_whitespace(string)
      end
    end

    private

    def license_names
      @license_titles ||= License.all(hidden: true).map do |license|
        regex = ALT_TITLE_REGEX[license.key]
        regex || license.name_without_version.downcase.sub('*', 'u')
      end
    end

    def title_regex
      /\A\(?(the )?(#{Regexp.union(license_names).source}).*$/i
    end

    def strip_title(string)
      string.sub(title_regex, '').strip
    end

    def strip_version(string)
      string.sub(/\Aversion.*$/i, '').strip
    end

    def strip_copyright(string)
      string.gsub(Matchers::Copyright::REGEX, '').strip
    end

    # Strip HRs from MPL
    def strip_hrs(string)
      string.gsub HR_REGEX, ' '
    end

    # Strip leading #s from the document
    def strip_markdown_headings(string)
      string.sub(/\A\s*#+/, '').strip
    end

    def strip_whitespace(string)
      string.gsub(/\s+/, ' ').squeeze(' ').strip
    end
  end
end
