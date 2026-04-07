# frozen_string_literal: true

module Licensee
  module ContentHelper
    # Mixin providing wordset-based similarity scoring.
    module SimilarityMethods
      # Given another license or project file, calculates the similarity
      # as a percentage of words in common, minus a tiny penalty that
      # increases with size difference between licenses so that false
      # positives for long licenses are ruled out by this score alone.
      def similarity(other)
        overlap = (wordset_fieldless & other.wordset).size
        (overlap * 200.0) / similarity_denominator(other)
      end

      # Given another license or project file, calculates the Dice coefficient
      # over bigrams (consecutive word pairs).  Unlike wordset similarity this
      # is sensitive to word order, making it resistant to adversarial scrambling
      # where all the correct words appear but in the wrong sequence.
      def bigram_similarity(other)
        my_bigrams = bigrams
        other_bigrams = other.bigrams
        total = my_bigrams.size + other_bigrams.size
        return 0.0 if total.zero?

        overlap = (my_bigrams & other_bigrams).size
        (overlap * 200.0) / total
      end

      private

      def wordset_fieldless
        @wordset_fieldless ||= wordset - fields_normalized_set
      end

      def similarity_denominator(other)
        total = wordset_fieldless.size + other.wordset.size - fields_normalized_set.size
        total + (variation_adjusted_length_delta(other) / 4)
      end

      # Returns an array of strings of substitutable fields in normalized content
      def fields_normalized
        @fields_normalized ||= content_normalized.scan(LicenseField::FIELD_REGEX).flatten
      end

      def fields_normalized_set
        @fields_normalized_set ||= fields_normalized.to_set
      end

      def variation_adjusted_length_delta(other)
        delta = length_delta(other)

        # The content helper mixin is used in different objects
        # Licenses have a more advanced SPDX alt. segement-based delta.
        # Use that if it's present, otherwise, just return the simple delta.
        return delta unless respond_to?(:spdx_alt_segments, true)

        adjusted_delta = delta - ([fields_normalized.size, spdx_alt_segments].max * 5)
        adjusted_delta.positive? ? adjusted_delta : 0
      end
    end
  end
end
