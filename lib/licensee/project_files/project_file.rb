# frozen_string_literal: true

# A project file is a file within a project that contains license information
# Currently extended by LicenseFile, PackageManagerFile, and ReadmeFile
#
# Sublcasses should implement the possible_matchers method
module Licensee
  module ProjectFiles
    class ProjectFile < ContentFile
      extend Forwardable
      def_delegator :@data, :[]

      include Licensee::HashHelper
      HASH_METHODS = %i[
        filename content content_hash content_normalized matcher matched_license
        attribution
      ].freeze

      def possible_matchers
        raise 'Not implemented'
      end

      def matcher
        @matcher ||= possible_matchers.map { |m| m.new(self) }.find(&:match)
      end

      # Returns the percent confident with the match
      def confidence
        matcher&.confidence
      end

      def license
        matcher&.match
      end

      alias match license

      def matched_license
        license&.spdx_id
      end

      # Is this file a COPYRIGHT file with only a copyright statement?
      # If so, it can be excluded from determining if a project has >1 license
      def copyright?
        return false unless is_a?(LicenseFile)
        return false unless matcher.is_a?(Matchers::Copyright)

        filename =~ /\Acopyright(?:#{LicenseFile::OTHER_EXT_REGEX})?\z/io
      end

      def content_hash
        nil
      end

      def content_normalized
        nil
      end

      def attribution
        nil
      end
    end
  end
end
