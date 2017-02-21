require 'set'
require 'digest'

module Licensee
  module ContentHelper
    DIGEST = Digest::SHA1

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
      (length * Licensee.inverse_confidence_threshold).to_i
    end

    # Given another license or project file, calculates the difference in length
    def length_delta(other)
      (length - other.length).abs
    end

    # Modify similarlity to avoid known false positives in context of particular
    # licenses eg https://github.com/benbalter/licensee/issues/116
    def license_similarity(other)
      s = similarity(other)
      if key.start_with?('cc-by') &&
         s >= Licensee.confidence_threshold &&
         (other.content.include?('NonCommercial') ||
          other.content.include?('NoDeriv'))
        return Licensee.confidence_threshold - 1
      end
      s
    end

    # Given another license or project file, calculates the similarity
    # as a percentage of words in common
    def similarity(other)
      overlap = (wordset & other.wordset).size
      total = wordset.size + other.wordset.size
      100.0 * (overlap * 2.0 / total)
    end

    # SHA1 of the normalized content
    def hash
      @hash ||= DIGEST.hexdigest content_normalized
    end

    # Content with copyright header and linebreaks removed
    def content_normalized
      return unless content
      @content_normalized ||= begin
        string = content.downcase.strip
        string = strip_title(string) while string =~ title_regex
        string = strip_version(string)
        string = strip_copyright(string)
        string = strip_hrs(string)
        strip_whitespace(string)
      end
    end

    private

    def license_names
      @license_titles ||= License.all(hidden: true).map do |license|
        license.name_without_version.downcase.sub('*', 'u')
      end
    end

    def title_regex
      /\A(the )?#{Regexp.union(license_names)}.*$/i
    end

    def strip_title(string)
      string.sub(title_regex, '').strip
    end

    def strip_version(string)
      string.sub(/\Aversion.*$/i, '').strip
    end

    def strip_copyright(string)
      string.gsub(/\A#{Matchers::Copyright::REGEX}$/i, '').strip
    end

    # Strip HRs from MPL
    def strip_hrs(string)
      string.gsub(/[=-]{4,}/, '')
    end

    def strip_whitespace(string)
      string.tr("\n", ' ').squeeze(' ').strip
    end
  end
end
