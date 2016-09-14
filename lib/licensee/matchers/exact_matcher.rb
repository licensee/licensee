module Licensee
  module Matchers
    class Exact
      def initialize(file)
        @file = file
      end

      def match
        Licensee.licenses(hidden: true).find do |license|
          license.length == @file.length && license.wordset == @file.wordset
        end
      end

      def confidence
        100
      end
    end
  end
end
