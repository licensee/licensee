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
        return @match if defined? @match
        matches = potential_licenses.map do |license|
          similarity = license.similarity(file)
          [license, similarity] if similarity >= Licensee.confidence_threshold
        end
        matches.compact!
        @match = if matches.empty?
          nil
        else
          matches.max_by { |_l, sim| sim }.first
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

      # Confidence that the matched license is a match
      def confidence
        @confidence ||= match ? file.similarity(match) : 0
      end
    end
  end
end
