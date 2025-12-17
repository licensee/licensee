# frozen_string_literal: true

module Licensee
  module Matchers
    # Exact matcher that succeeds when the license file's normalized wordset
    # exactly matches a known license's normalized wordset.
    class Exact < Licensee::Matchers::Matcher
      def match
        return @match if defined? @match

        @match = potential_matches.find do |potential_match|
          potential_match.wordset == file.wordset
        end
      end

      def confidence
        100
      end
    end
  end
end
