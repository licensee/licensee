# frozen_string_literal: true

module Licensee
  module Matchers
    class Copyright < Licensee::Matchers::Matcher
      attr_reader :file

      COPYRIGHT_SYMBOLS = Regexp.union([/copyright/i, /\(c\)/i, "\u00A9", "\xC2\xA9"])
      REGEX = /#{ContentHelper::START_REGEX}([_*\-\s]*#{COPYRIGHT_SYMBOLS}.*$)+$/i.freeze
      def match
        # NOTE: must use content, and not content_normalized here
        Licensee::License.find('no-license') if /#{REGEX}+\z/io.match?(file.content.strip)
      rescue Encoding::CompatibilityError
        nil
      end

      def confidence
        100
      end
    end
  end
end
