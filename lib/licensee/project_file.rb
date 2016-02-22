module Licensee
  class Project
    class File
      attr_reader :content, :filename

      def initialize(content, filename = nil)
        @content = content
        options = { invalid: :replace, undef: :replace, replace: '' }
        @content.encode!(Encoding::UTF_8, options)
        @filename = filename
      end

      def matcher
        @matcher ||= possible_matchers.map { |m| m.new(self) }.find(&:match)
      end

      # Returns the percent confident with the match
      def confidence
        matcher && matcher.confidence
      end

      def license
        matcher && matcher.match
      end

      alias match license
      alias path filename
    end
  end
end
