require 'charlock_holmes'

module Licensee
  class Project
    class File
      attr_reader :content, :filename

      def initialize(content, filename = nil)
        @content = content
        unless @content.empty?
          detection = CharlockHolmes::EncodingDetector.detect(content)
          @content = CharlockHolmes::Converter.convert @content,
                                                       detection[:encoding],
                                                       'UTF-8'
        end
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
