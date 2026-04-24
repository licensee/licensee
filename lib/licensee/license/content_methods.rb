# frozen_string_literal: true

module Licensee
  class License
    # Instance methods for loading and working with license content.
    module ContentMethods
      # Path to vendored license file on disk
      def path
        @path ||= File.expand_path "#{@key}.txt", Licensee::License.license_dir
      end

      # The license body (e.g., contents - frontmatter)
      def content
        @content ||= parts[2] if parts && parts[2]
      end
      alias to_s content
      alias text content
      alias body content

      # Returns an array of strings of substitutable fields in the license body
      def fields
        @fields ||= LicenseField.from_content(content)
      end

      # Returns a string with `[fields]` replaced by `{{{fields}}}`
      # Does not mangle non-supported fields in the form of `[field]`
      def content_for_mustache
        @content_for_mustache ||= content.gsub(LicenseField::FIELD_REGEX, '{{{\1}}}')
      end

      # Returns the minimum dice similarity (0–100) required to match this
      # license.  For highly-templated licenses (those with many SPDX
      # `<alt>` segments) the threshold is reduced slightly so that valid
      # textual variations accepted by SPDX still score as matches.
      # The reduction is 0.2 percentage points per alt segment, capped at 2 pp,
      # keeping the floor at 95 regardless of the configured threshold.
      def minimum_matching_confidence
        alt_count = spdx_alt_segments
        return Licensee.confidence_threshold if alt_count.zero?

        reduction = [alt_count * 0.2, 2.0].min
        [Licensee.confidence_threshold - reduction, 95.0].max
      end

      private

      # Raw content of license file, including YAML front matter
      def raw_content
        return if pseudo_license?
        raise Licensee::InvalidLicense, "'#{key}' is not a valid license key" unless File.exist?(path)

        @raw_content ||= File.read(path, encoding: 'utf-8')
      end

      def parts
        return unless raw_content

        @parts ||= raw_content.match(/\A(---\n.*\n---\n+)?(.*)/m).to_a
      end

      def yaml
        @yaml ||= parts[1] if parts
      end
    end
  end
end
