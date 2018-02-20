module Licensee
  module Matchers
    class Exact < Licensee::Matchers::Matcher
      def match
        return @match if defined? @match
        @match = Licensee.licenses(hidden: true).find do |license|
          license.length == @file.length && license.wordset == @file.wordset
        end
      end

      def confidence
        100
      end
    end
  end
end
