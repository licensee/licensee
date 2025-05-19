# frozen_string_literal: true

module Licensee
  module Matchers
    # Matches a license based on an SPDX license expression
    # Example: SPDX-License-Identifier: MIT
    # Example: SPDX-License-Identifier: Apache-2.0 OR GPL-2.0-or-later
    class SpdxExpression < Licensee::Matchers::Matcher
      # Regex to match SPDX license identifiers in license files
      # https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions/
      SPDX_REGEX = /SPDX-License-Identifier:\s*(.+)/i

      # The license expression from the file
      attr_reader :license_expression

      private

      def matches_license(license)
        return false unless license

        @license_expression.match?(license.spdx_id.to_s) ||
          @license_expression.match?(license.key.to_s)
      end

      def match
        return @match if defined? @match

        if spdx_expression
          @license_expression = spdx_expression
          
          # First try to find exact matches for SPDX IDs
          spdx_ids = extract_licenses_from_expression(@license_expression)
          license = find_by_spdx_id(spdx_ids.first) if spdx_ids.any?
          
          @match = license
          @confidence = license ? 100 : 0
        end

        @match
      end

      def spdx_expression
        match = @file.content.match SPDX_REGEX
        return unless match && match[1]

        match[1].strip
      end

      # Extract license IDs from a license expression
      # For simple expressions like "MIT", returns ["MIT"]
      # For compound expressions like "MIT OR Apache-2.0", returns ["MIT", "Apache-2.0"]
      def extract_licenses_from_expression(expression)
        # This is a simplistic implementation that splits on OR and AND
        # A full SPDX expression parser would be more robust
        expression.split(/\s+(?:OR|AND)\s+/)
                  .map { |id| id.gsub(/[()]/, '').strip }
                  .reject(&:empty?)
      end

      # Try to find a license by SPDX ID
      def find_by_spdx_id(spdx_id)
        # For handling "or later" versions
        normalized_spdx_id = spdx_id.sub(/-or-later$/, '+')
        
        License.all(hidden: true, pseudo: false).find do |license|
          license.spdx_id && [license.spdx_id, normalized_spdx_id].include?(spdx_id)
        end
      end

      def confidence
        @confidence
      end
    end
  end
end