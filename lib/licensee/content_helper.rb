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
        content_normalized = content.downcase.strip
        content_normalized.gsub!(/^#{Matchers::Copyright::REGEX}$/i, '')
        content_normalized.tr("\n", ' ').squeeze(' ').strip
      end
    end
  end
end
