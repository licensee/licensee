class Licensee
  class LicenseFile
    attr_reader :blob

    def initialize(blob)
      @blob = blob
    end

    def similarity(other)
      blob.hashsig(Rugged::Blob::HashSignature::WHITESPACE_SMART)
      other.hashsig ? blob.similarity(other.hashsig) : 0
    rescue Rugged::InvalidError
      0
    end

    # Raw file contents
    def content
      @contents ||= begin
        blob.content
      end
    end
    alias_method :to_s, :content
    alias_method :contents, :content

    # File content with all whitespace replaced with a single space
    def content_normalized
      @content_normalized ||= content.downcase.gsub(/\s+/, " ").strip
    end

    # Comptutes a diff between known license and project license
    def diff(options={})
      options = options.merge(:reverse => true)
      blob.diff(match.body, options).to_s if match
    end

    # Determines which matching strategy to use, returns an instane of that matcher
    def matcher
      @matcher ||= Licensee.matchers.map { |m| m.new(self) }.find { |m| m.match }
    end

    # Returns an Licensee::License instance of the matches license
    def match
      @match ||= matcher.match if matcher
    end

    # Returns the percent confident with the match
    def confidence
      @condience ||= matcher.confidence if matcher
    end
  end
end
