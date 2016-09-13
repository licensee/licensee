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

    # SHA1 of the normalized content
    def hash
      @hash ||= DIGEST.hexdigest content_normalized
    end

    # Content with copyright header and linebreaks removed for ease of comparison
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
