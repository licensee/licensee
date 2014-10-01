class Licensee
  class LicenseFile
    attr_reader :blob
    attr_accessor :max_delta

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

    def length_delta(license)
      (length - license.length).abs
    end

    def max_delta
      @max_delta ||= (length / 2)
    end

    def potential_licenses
      @potential_licenses ||= begin
        list = Licensee::Licenses.list
        max_delta ? list.select { |l| length_delta(l) <= max_delta } : list
      end
    end

    def matches
      @matches ||= potential_licenses.map { |l| [l, blob.similarity(l.hashsig)] }.to_h
    end

    def match_info
      @match_info ||= matches.max_by { |l, sim| sim }
    end
    
    def match
      match_info ? match_info[0] : nil
    end

    def confidence
      match_info ? match_info[1] : nil
    end

    def distance(other)
      blob.similarity(other.hashsig)
    end

    def diff(options=nil)
      # TODO
    end

    private
    def content_normalized
      contents.downcase.gsub(/\s+/, "")
    end
  end
end
