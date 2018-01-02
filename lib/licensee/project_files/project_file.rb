# A project file is a file within a project that contains license information
# Currently extended by LicenseFile, PackageManagerFile, and ReadmeFile
#
# Sublcasses should implement the possible_matchers method
module Licensee
  module ProjectFiles
    class ProjectFile
      extend Forwardable
      def_delegator :@data, :[]

      attr_reader :content

      ENCODING = Encoding::UTF_8
      ENCODING_OPTIONS = {
        invalid: :replace,
        undef:   :replace,
        replace: ''
      }.freeze

      # Create a new Licensee::ProjectFile with content and metadata
      #
      # content - file content
      # metadata - can be either the string filename, or a hash containing
      #            metadata about the file content. If a hash is given, the
      #            filename should be given using the :name key. See individual
      #            project types for additional available metadata
      #
      # Returns a new Licensee::ProjectFile
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

      def possible_matchers
        raise 'Not implemented'
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

      # Is this file a COPYRIGHT file with only a copyright statement?
      # If so, it can be excluded from determining if a project has >1 license
      def copyright?
        return false unless is_a?(LicenseFile)
        return false unless matcher.is_a?(Matchers::Copyright)
        filename =~ /\Acopyright(?:#{LicenseFile::OTHER_EXT_REGEX})?\z/i
      end
    end
  end
end
