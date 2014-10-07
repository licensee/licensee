class Licensee
  class GitMatcher < Matcher

    def matches
      @matches ||= Licensee::Licenses.list.map { |l| [l, similarity(l)] }.select { |l,sim| sim > 0 }
    end

    def match
      match_info ? match_info[0] : nil
    end

    def confidence
      match_info ? match_info[1] : nil
    end

    private

    def similarity(other)
      file.blob.similarity(other.hashsig)
    end

    # Pulled out for easier testing
    def match_info
      @match_info ||= begin
        match = matches.max_by { |license, similarity| similarity }
        match if match[1] > Licensee::CONFIDENCE_THRESHOLD
      end
    end
  end
end
