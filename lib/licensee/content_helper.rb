require 'set'
require 'digest'

module Licensee
  module ContentHelper
    DIGEST = Digest::SHA1

    def wordset
      @wordset ||= if content_normalized
        content_normalized.scan(/[\w']+/).to_set
      end
    end

    def hash
      @hash ||= DIGEST.hexdigest content_normalized
    end

    def content_normalized
      return unless content
      @content_normalized ||= begin
        content_normalized = content.downcase.strip
        content_normalized.gsub!(/^#{Matchers::Copyright::REGEX}$/i, '')
        content_normalized.tr("\n", ' ').squeeze(' ')
      end
    end
  end
end
