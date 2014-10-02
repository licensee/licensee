class Licensee
  class LicenseFile
    attr_reader :blob

    def initialize(blob)
      @blob = blob
      blob.hashsig(Rugged::Blob::HashSignature::WHITESPACE_SMART)
    end

    def contents
      @contents ||= blob.content
    end
    alias_method :to_s, :contents
    alias_method :content, :contents

    def length
      @length ||= blob.size
    end

    def matches
      @matches ||= Licensee::Licenses.list.map { |l| [l, calculate_similarity(l)] }
    end

    def match_info
      @match_info ||= matches.max_by { |license, similarity| similarity }
    end

    def match
      match_info ? match_info[0] : nil
    end

    def confidence
      match_info ? match_info[1] : nil
    end
    alias_method :similarity, :confidence

    def diff(options={})
      options = options.merge(:reverse => true)
      blob.diff(match.body, options).to_s if match
    end

    private

    # Pulled out for easier testing
    def calculate_similarity(other)
      blob.similarity(other.hashsig)
    end
  end
end
