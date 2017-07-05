require 'forwardable'

module Licensee
  class Project
    class File
      extend Forwardable

      attr_reader :content

      ENCODING = Encoding::UTF_8
      ENCODING_OPTIONS = {
        invalid: :replace,
        undef:   :replace,
        replace: ''
      }.freeze

      # Create a new Licensee::Project::File with content and metadata
      #
      # content - file content
      # metadata - can be either the string filename, or a hash containing
      #            metadata about the file content.  If a hash is given, the
      #            filename should be given using the :name key.  See individual
      #            project types for additional available metadata
      #
      # Returns a new Licensee::Project::File
      def initialize(content, metadata = {})
        @content = content
        @content.force_encoding(ENCODING)
        unless @content.valid_encoding?
          @content.encode!(ENCODING, ENCODING_OPTIONS)
        end

        metadata = { name: metadata } if metadata.is_a? String
        @data = metadata || {}
      end

      def filename
        @data[:name]
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
      def_delegator :@data, :[]
    end
  end
end
