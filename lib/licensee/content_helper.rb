class Licensee
  module ContentHelper
    def normalize_content(content)
      return unless content
      content = content.downcase
      content = content.gsub(/\A[[:space:]]+/, '')
      content = content.gsub(/[[:space:]]+\z/, '')
      content = content.gsub(/^#{CopyrightMatcher::REGEX}$/i, '')
      content = content.gsub(/[[:space:]]+/, ' ')
      content = content.gsub("\u0000", '') # Remove null byte which breaks Levenshtein
      content.squeeze(' ').strip
    end
  end
end
