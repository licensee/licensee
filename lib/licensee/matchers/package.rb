# frozen_string_literal: true

module Licensee
  module Matchers
    # Base matcher for package manager metadata files declaring a license.
    class Package < Licensee::Matchers::Matcher
      # Regex matching SPDX compatibility suffixes that have no matching
      # license entry in the database (e.g. LGPL-3.0-or-later → lgpl-3.0).
      SPDX_SUFFIX_REGEX = /-or-later\z|-only\z/i

      # Regex matching individual SPDX expression tokens (license IDs or operators).
      SPDX_TOKEN_REGEX = /[A-Za-z0-9.\-+]+/

      # SPDX boolean operators to skip when parsing compound expressions.
      SPDX_OPERATORS = %w[OR AND WITH].freeze

      def match
        return @match if defined? @match

        prop = license_property
        return if prop.nil? || prop.to_s.empty?

        licenses = Licensee.licenses(hidden: true)
        @match = licenses.find { |l| l.key == prop }
        @match ||= match_by_spdx_base_key(prop, licenses)
        @match ||= License.find('other')
      end

      def confidence
        90
      end

      # Returns all licenses found in a compound SPDX expression such as
      # "MIT OR Apache-2.0". Unknown identifiers resolve to the 'other'
      # (NOASSERTION) license. Returns nil when the property is absent or
      # contains only a single token (plain license key).
      def spdx_expression_licenses
        return @spdx_expression_licenses if defined? @spdx_expression_licenses

        @spdx_expression_licenses = resolve_spdx_expression_licenses
      end

      def license_property
        raise NotImplementedError, "#{self.class}#license_property is not implemented"
      end

      private

      def find_license_for_token(token, licenses)
        key = token.downcase
        licenses.find { |l| l.key == key } ||
          match_by_spdx_base_key(key, licenses)
      end

      def spdx_expression_tokens(prop)
        prop.scan(SPDX_TOKEN_REGEX).reject { |t| SPDX_OPERATORS.include?(t.upcase) }
      end

      def resolve_spdx_expression_licenses
        prop = license_property
        return nil if prop.nil? || prop.to_s.empty?

        tokens = spdx_expression_tokens(prop)
        return nil if tokens.size <= 1

        licenses = Licensee.licenses(hidden: true)
        other = License.find('other')
        tokens.map { |t| find_license_for_token(t, licenses) || other }
      end

      def match_by_spdx_base_key(prop, licenses)
        base = prop.sub(SPDX_SUFFIX_REGEX, '')
        return if base == prop

        licenses.find { |l| l.key == base }
      end
    end
  end
end
