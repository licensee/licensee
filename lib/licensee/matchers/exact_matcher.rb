class Licensee
  module Matcher
    class Exact
      def initialize(file)
        @file = file
      end

      def match
        Licensee.licenses(:hidden => true).find { |l| l.wordset == @file.wordset }
      end

      def confidence
        100
      end
    end
  end
end
