require 'set'
require 'digest'

class Licensee
  module ContentHelper

    DIGEST = Digest::SHA1

    def create_word_set(content)
      return unless content
      content = content.dup
      content.downcase!
      content.gsub!(/^#{Matchers::Copyright::REGEX}$/i, '')
      content.scan(/[\w']+/).to_set
    end

    def hash
      @hash ||= DIGEST.hexdigest(content)
    end
  end
end
