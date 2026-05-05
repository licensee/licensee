# frozen_string_literal: true

module Licensee
  module Matchers
    # Matches license identifiers in Cabal package files.
    class Cabal < Licensee::Matchers::Package
      # While we could parse the cabal file, prefer
      # a lenient regex for speed and security. Moar parsing moar problems.
      # The "+" suffix is the pre-SPDX Cabal notation for "or-later" (e.g. GPL-2+).
      LICENSE_REGEX = /^\s*license\s*:\s*([a-z\-0-9.+]+)\s*$/ix
      LICENSE_CONVERSIONS = {
        'GPL-2'  => 'GPL-2.0',
        'GPL-3'  => 'GPL-3.0',
        'LGPL-3' => 'LGPL-3.0',
        'AGPL-3' => 'AGPL-3.0',
        'BSD2'   => 'BSD-2-Clause',
        'BSD3'   => 'BSD-3-Clause'
      }.freeze

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        spdx_name(match[1]).downcase if match && match[1]
      end

      def spdx_name(cabal_name)
        # Strip pre-SPDX "or-later" suffix (+) before looking up conversions
        normalized = cabal_name.chomp('+')
        LICENSE_CONVERSIONS[normalized] || normalized
      end
    end
  end
end
