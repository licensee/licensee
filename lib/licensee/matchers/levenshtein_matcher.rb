class Licensee
  class LevenshteinMatcher < Matcher

    def match
      @match ||= potential_licenses.find do |license|
        similarity(license) >= Licensee::CONFIDENCE_THRESHOLD
      end
    end

    def potential_licenses
      @potential_licenses ||= begin
        Licensee::Licenses.list.select { |license| length_delta(license) <= max_delta }.sort_by { |l| length_delta(l) }.reverse
      end
    end

    def length_delta(license)
      (file_length - license.body_normalized.length).abs
    end

    def max_delta
      @max_delta ||= (file_length * (Licensee::CONFIDENCE_THRESHOLD.to_f / 100.to_f ))
    end

    def confidence
      @confidence ||= match ? similarity(match) : 0
    end

    private

    def file_length
      @file_length ||= file.content_normalized.length
    end

    def similarity(license)
      100 * (file_length - distance(license)) / file_length
    end

    def distance(license)
      Levenshtein.distance(license.body_normalized, file.content_normalized).to_f
    end
  end
end
