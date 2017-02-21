module Licensee
  module Matchers
    class FalsePositive
      attr_reader :file

      # CC-NC and CC-ND are not open source licenses and should always be
      # detected as the "other" license
      REGEX = /\A(creative commons )?Attribution-(NonCommercial|NoDerivatives)/i

      def initialize(file)
        @file = file
      end

      def match
        other_license if @file.content.strip =~ REGEX
      end

      def confidence
        100
      end

      private

      def other_license
        @other_license ||= Licensee::License.find('other')
      end
    end
  end
end
