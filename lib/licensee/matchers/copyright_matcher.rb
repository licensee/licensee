# encoding=utf-8
module Licensee
  module Matchers
    class Copyright
      attr_reader :file

      # rubocop:disable Metrics/LineLength
      REGEX = /\s*(This software is )?([Cc]opyright|\(c\)) (©|\(c\)|\xC2\xA9)? ?(\d{4}|\[year\])(.*)?\s*/i

      def initialize(file)
        @file = file
      end

      def match
        # Note: must use content, and not content_normalized here
        if @file.content.strip =~ /\A#{REGEX}\z/i
          Licensee::License.find('no-license')
        end
      rescue
        nil
      end

      def confidence
        100
      end
    end
  end
end
