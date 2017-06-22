module Licensee
  module Matchers
    class Package
      def initialize(file)
        @file = file
      end

      def match
        Licensee.licenses(hidden: true)
                .find { |l| l.key == license_property } ||
          Licensee::License.find('other')
      end

      def confidence
        90
      end
    end
  end
end
