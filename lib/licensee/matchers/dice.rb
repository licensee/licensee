# frozen_string_literal: true

module Licensee
  module Matchers
    # Similarity matcher based on the Dice coefficient over wordsets.
    class Dice < Licensee::Matchers::Matcher
      # Return the first potential license that is more similar
      # than the confidence threshold
      def match
        @match ||= if matches.empty?
                     nil
                   else
                     matches.first[0]
                   end
      end

      # Licenses that may be a match for this file.
      # To avoid false positives:
      #
      # 1. Creative commons licenses cannot be matched against license files
      #    that begin with the title of a non-open source CC license variant
      # 2. The percentage change in file length may not exceed the inverse
      #    of the confidence threshold
      def potential_matches
        @potential_matches ||= super.select do |license|
          if license.creative_commons? && file.potential_false_positive?
            false
          else
            license.wordset
          end
        end
      end
      alias potential_licenses potential_matches

      def matches_by_similarity
        @matches_by_similarity ||= begin
          matches = potential_matches.map do |potential_match|
            [potential_match, potential_match.similarity(file)]
          end
          matches.sort_by { |_, similarity| similarity }.reverse
        end
      end
      alias licenses_by_similarity matches_by_similarity

      def matches
        @matches ||= matches_by_similarity.select do |license, similarity|
          similarity >= minimum_confidence_for(license) &&
            license.bigram_similarity(file) >= minimum_bigram_confidence
        end
      end

      # Confidence that the matched license is a match
      def confidence
        @confidence ||= match ? match.similarity(file) : 0
      end

      private

      def minimum_confidence
        Licensee.confidence_threshold
      end

      # Per-license threshold: honours the license's own minimum if it
      # advertises one (e.g. to tolerate valid SPDX alt-text variants),
      # falling back to the global confidence threshold.
      def minimum_confidence_for(license)
        if license.respond_to?(:minimum_matching_confidence)
          license.minimum_matching_confidence
        else
          minimum_confidence
        end
      end

      # A floor for bigram similarity, used to reject adversarially scrambled
      # content that achieves high wordset similarity by including all the right
      # words in the wrong order.  Set to half the wordset threshold so that any
      # genuine license match (which typically scores 90%+ on bigrams) passes,
      # while scrambled content (which scores near 0%) is rejected.
      def minimum_bigram_confidence
        Licensee.confidence_threshold / 2.0
      end
    end
  end
end
