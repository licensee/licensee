class Licensee
  class GitMatcher < Matcher

    def match
      match_info[0] unless match_info.nil?
    end

    def confidence
      match_info[1] unless match_info.nil?
    end

    private

    def matches
      @matches ||= Licensee.licenses.map { |l| [l, similarity(l)] }.select { |l,sim| sim > 0 }
    end

    def similarity(other)
      file.blob.similarity(other.hashsig)
    end

    # Pulled out for easier testing
    def match_info
      @match_info ||= begin
        match = matches.max_by { |license, similarity| similarity }
        match if match && match[1] > Licensee::CONFIDENCE_THRESHOLD
      end
    end
  end
end
