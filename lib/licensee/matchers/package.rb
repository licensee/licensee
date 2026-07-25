# frozen_string_literal: true

module Licensee
  module Matchers
    # Base matcher for package manager metadata files declaring a license.
    class Package < Licensee::Matchers::Matcher
      # Regex matching SPDX compatibility suffixes that have no matching
      # license entry in the database (e.g. LGPL-3.0-or-later → lgpl-3.0).
      SPDX_SUFFIX_REGEX = /-or-later\z|-only\z/i

      # Regex matching individual SPDX license identifier tokens within
      # compound expressions (e.g. "MIT OR Apache-2.0" → ["MIT", "Apache-2.0"]).
      SPDX_TOKEN_REGEX = /[A-Za-z0-9][A-Za-z0-9.-]*/

      # SPDX expression operator keywords that are not license identifiers.
      SPDX_OPERATORS = %w[or and with].freeze

      def match
        return @match if defined? @match

        prop = license_property
        return if prop.nil? || prop.to_s.empty?

        @match = find_license_match(prop)
      end

      def confidence
        90
      end

      def license_property
        raise NotImplementedError, "#{self.class}#license_property is not implemented"
      end

      private

      def find_license_match(prop)
        licenses = Licensee.licenses(hidden: true)
        licenses.find { |l| l.key == prop } ||
          match_by_spdx_base_key(prop, licenses) ||
          match_by_spdx_expression(prop, licenses) ||
          License.find('other')
      end

      def match_by_spdx_base_key(prop, licenses)
        base = prop.sub(SPDX_SUFFIX_REGEX, '')
        return if base == prop

        licenses.find { |l| l.key == base }
      end

      # Extracts individual SPDX license IDs from a compound SPDX expression
      # and returns the first one that resolves to a known license. This handles
      # expressions such as "MIT OR Apache-2.0" or "(LGPL-2.1 OR GPL-3.0)".
      def match_by_spdx_expression(prop, licenses)
        prop.scan(SPDX_TOKEN_REGEX)
            .reject { |t| SPDX_OPERATORS.include?(t.downcase) }
            .filter_map { |t| find_license_by_spdx_token(t, licenses) }
            .first
      end

      def find_license_by_spdx_token(token, licenses)
        licenses.find { |l| l.key == token.downcase } ||
          licenses.find { |l| l.key == token.sub(SPDX_SUFFIX_REGEX, '').downcase }
      end
    end
  end
end
