module Licensee
  module Matchers
    class Dice
      attr_reader :file

      def initialize(file)
        @file = file
      end

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
      # To avoid false positives, the percentage change in file length
      # may not exceed the inverse of the confidence threshold
      def potential_licenses
        @potential_licenses ||= begin
          Licensee.licenses(hidden: true).select do |license|
            license.wordset && license.length_delta(file) <= license.max_delta
          end
        end
      end

      def licenses_by_similiarity
        @licenses_by_similiarity ||= begin
          licenses =
            potential_licenses.map { |l| [l, l.license_similarity(file)] }
          licenses.sort_by { |_, similarity| similarity }.reverse
        end
      end

      def matches
        @matches ||= licenses_by_similiarity.select do |_, similarity|
          similarity >= Licensee.confidence_threshold
        end
      end

      # Confidence that the matched license is a match
      def confidence
        @confidence ||= match ? file.similarity(match) : 0
      end
    end
  end
end
