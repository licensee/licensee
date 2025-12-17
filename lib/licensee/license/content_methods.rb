# frozen_string_literal: true

module Licensee
  class License
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
