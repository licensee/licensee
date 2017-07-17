module Licensee
  module Matchers
    class Matcher
      attr_reader :file

      def initialize(file)
        @file = file
      end

      def match
        raise 'Not implemented'
      end

      def confidence
        raise 'Not implemented'
      end
    end
  end
end
