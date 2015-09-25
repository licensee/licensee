class Licensee
  module Matchers
    class Dice
      def initialize(file)
        @file = file
      end

      # Return the first potential license that is more similar
      # than the confidence threshold
      def match
        return @match if defined? @match
        @match = potential_licenses.find do |license|
          similarity(license) >= Licensee.confidence_threshold
        end
      end

      # Sort all licenses, in decending order, by difference in
      # length to the file
      # Difference in lengths cannot exceed the file's length *
      # the confidence threshold / 100
      def potential_licenses
        @potential_licenses ||= begin
          licenses = Licensee.licenses(:hidden => true)
          licenses = licenses.select do |license|
            license.wordset && length_delta(license) <= max_delta
          end
          licenses.sort_by { |l| length_delta(l) }
        end
      end

      # Calculate the difference between the file length and a given
      # license's length
      def length_delta(license)
        (@file.wordset.size - license.wordset.size).abs
      end

      # Maximum possible difference between file length and license length
      # for a license to be a potential license to be matched
      def max_delta
        @max_delta ||= (@file.wordset.size * (Licensee.confidence_threshold/100.0))
      end

      # Confidence that the matched license is a match
      def confidence
        @confidence ||= match ? similarity(match) : 0
      end

      private
      # Calculate percent changed between file and potential license
      def similarity(license)
        overlap = (@file.wordset & license.wordset).size
        total = @file.wordset.size + license.wordset.size
        100.0 * (overlap * 2.0 / total)
      end
    end
  end
end
