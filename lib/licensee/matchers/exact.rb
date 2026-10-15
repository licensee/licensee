# frozen_string_literal: true

module Licensee
  module Matchers
    # Exact matcher that compares the complete normalized license text.
    class Exact < Licensee::Matchers::Matcher
      def match
        return @match if defined? @match

        @match = potential_matches.find do |potential_match|
          potential_match.content_normalized == file.content_normalized
        end
      end

      def confidence
        100
      end
    end
  end
end
