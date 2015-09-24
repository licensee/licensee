class Licensee
  module ContentHelper
    def create_word_set(content)
      return unless content
      content = content.dup
      content.downcase!
      content.gsub!(/^#{Matcher::Copyright::REGEX}$/i, '')
      content.scan(/[\w']+/).to_set
    end
  end
end
