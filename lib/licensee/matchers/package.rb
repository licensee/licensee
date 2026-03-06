# frozen_string_literal: true

module Licensee
  module Matchers
    # Base matcher for package manager metadata files declaring a license.
    class Package < Licensee::Matchers::Matcher
      # Regex matching SPDX compatibility suffixes that have no matching
      # license entry in the database (e.g. LGPL-3.0-or-later → lgpl-3.0).
      SPDX_SUFFIX_REGEX = /-or-later\z|-only\z/i

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

      def license_property
        raise 'Not implemented'
      end

      private

      def match_by_spdx_base_key(prop, licenses)
        base = prop.sub(SPDX_SUFFIX_REGEX, '')
        return if base == prop

        licenses.find { |l| l.key == base }
      end
    end
  end
end
