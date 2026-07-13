# frozen_string_literal: true

module Licensee
  module Matchers
    # Matches license identifiers in pyproject.toml.
    # Based on Matchers::Cargo
    class PyProject < Licensee::Matchers::Package
      LICENSE_REGEX = /^\s*['"]?license['"]?\s*=\s*['"]([^'"]+)['"]\s*/ix

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        match[1].downcase if match && match[1]
      end
    end
  end
end
