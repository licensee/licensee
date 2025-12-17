# frozen_string_literal: true

module Licensee
  class License
    # Class-level lookup and caching for licenses.
    module ClassMethods
      # All license objects defined via Licensee (via choosealicense.com)
      #
      # Options:
      # - :hidden - boolean, return hidden licenses (default: false)
      # - :featured - boolean, return only (non)featured licenses (default: all)
      #
      # Returns an Array of License objects.
      def all(options = {})
        @all[options] ||= begin
          normalized_options = LicenseAllHelper.normalize_all_options(options, DEFAULT_OPTIONS)
          output = licenses.dup
          LicenseAllHelper.apply_all_filters!(output, normalized_options)
          output.sort_by!(&:key)
          LicenseAllHelper.filter_featured(output, normalized_options[:featured])
        end
      end

      def keys
        @keys ||= license_files.map do |license_file|
          ::File.basename(license_file, '.txt').downcase
        end + PSEUDO_LICENSES
      end

      def find(key, options = {})
        options = { hidden: true }.merge(options)
        keys_licenses(options)[key.downcase]
      end
      alias [] find
      alias find_by_key find

      # Given a license title or nickname, fuzzy match the license
      def find_by_title(title)
        License.all(hidden: true, pseudo: false).find do |license|
          title =~ /\A(the )?#{license.title_regex}( license)?\z/i
        end
      end

      def license_dir
        ::File.expand_path '../../../vendor/choosealicense.com/_licenses', __dir__
      end

      def license_files
        @license_files ||= Dir.glob("#{license_dir}/*.txt")
      end

      def spdx_dir
        ::File.expand_path '../../../vendor/license-list-XML/src', __dir__
      end

      private

      def licenses
        @licenses ||= keys.map { |key| new(key) }
      end

      def keys_licenses(options = {})
        @keys_licenses[options] ||= all(options).to_h { |l| [l.key, l] }
      end
    end
  end
end
