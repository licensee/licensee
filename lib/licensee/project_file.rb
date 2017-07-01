module Licensee
  class Project
    class File
      attr_reader :content

      ENCODING = Encoding::UTF_8
      ENCODING_OPTIONS = {
        invalid: :replace,
        undef:   :replace,
        replace: ''
      }.freeze

      def initialize(content, file = {})
        @content = content
        @content.force_encoding(ENCODING)
        unless @content.valid_encoding?
          @content.encode!(ENCODING, ENCODING_OPTIONS)
        end
        file = { name: file } if file.is_a? String
        @file = file || {}
      end

      def filename
        @file[:name]
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

      def [](key)
        @file[key]
      end

      alias match license
      alias path filename
    end
  end
end
