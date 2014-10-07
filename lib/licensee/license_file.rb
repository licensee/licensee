class Licensee
  class LicenseFile
    attr_reader :blob

    def initialize(blob)
      @blob = blob
      blob.hashsig(Rugged::Blob::HashSignature::WHITESPACE_SMART)
    end

    def content
      @contents ||= begin
        blob.content
      end
    end
    alias_method :to_s, :content
    alias_method :contents, :content

    def content_wrapped

    end

    def content_normalized
      @content_normalized ||= content.downcase.gsub("\n", " ").strip
    end

    def diff(options={})
      options = options.merge(:reverse => true)
      blob.diff(match.body, options).to_s if match
    end

    def matcher
      @matcher ||= Licensee.matchers.each do |matcher|
        matcher = matcher.new(self)
        break matcher if matcher.match
      end
    end

    def match
      @match ||= matcher.match if matcher
    end

    def confidence
      @condience ||= matcher.confidence
    end
  end
end
