# frozen_string_literal: true

module Licensee
  module ContentHelper
    # Detect aggregated LICENSE files (Tor, Debian, etc.) and match only the
    # primary license section before per-component attributions.
    module CompoundLicenseMethods
      # Long horizontal rules often delimit bundled license sections in
      # aggregated LICENSE files (Debian/Tor style).
      LONG_HRS_REGEX = /\A\s*([=\-*])\1{29,}\s*\z/

      # Text after a separator that introduces a third-party component license.
      COMPONENT_LICENSE_INTRO = /
        \A
        (?:
          (?:src\/|\S+\/\S+|\S+\.(?:c|cpp|cc|h|hpp|py|rs|go|java|js|ts))
          .{0,200}
        )?
        .*?
        \b(?:is|are)\s+(?:licensed|distributed)\s+under\b
      /xim

      def content_for_license_matching
        @content_for_license_matching ||= self.class.extract_primary_section(content.to_s.dup.strip)
      end

      module_function

      def extract_primary_section(text)
        lines = text.lines
        return text if lines.length < 5

        component_boundary = nil
        lines.each_with_index do |line, idx|
          next unless line.match?(Constants::REGEXES[:hrs])
          next unless line.match?(LONG_HRS_REGEX)

          remainder = lines[(idx + 1)..]&.join&.lstrip
          next unless remainder&.match?(COMPONENT_LICENSE_INTRO)

          component_boundary = idx
          break
        end

        return text unless component_boundary

        lines[0...component_boundary].join
      end
    end
  end
end
