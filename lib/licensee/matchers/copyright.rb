# frozen_string_literal: true

module Licensee
  module Matchers
    class Copyright < Licensee::Matchers::Matcher
      attr_reader :file

      # rubocop:disable Metrics/LineLength
      COPYRIGHT_SYMBOLS = Regexp.union([/copyright/i, /\(c\)/i, "\u00A9", "\xC2\xA9"])
      REGEX = /#{ContentHelper::START_REGEX}(?:portions )?(\s*#{COPYRIGHT_SYMBOLS}.*$)+$/i.freeze
      # rubocop:enable Metrics/LineLength

      def match
        # Note: must use content, and not content_normalized here
        if file.content.strip =~ /#{REGEX}+\z/i
          Licensee::License.find('no-license')
        end
      rescue Encoding::CompatibilityError
        nil
      end

      def confidence
        100
      end
    end
  end
end
