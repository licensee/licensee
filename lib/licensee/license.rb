class Licensee
  class License

    def self.all
      Licensee::licenses
    end

    attr_reader :key

    def initialize(key)
      @key=key.downcase
    end

    # Path to vendored license file on disk
    def path
      @path ||= File.expand_path "#{@key}.txt", Licensee::Licenses.base
    end

    # Raw content of license file, including YAML front matter
    def content
      @content ||= File.open(path).read
    rescue
      ""
    end

    # License metadata from YAML front matter
    def meta
      @meta ||= YAML.load(parts[1]) if parts[1]
    rescue
      nil
    end

    def name
      meta["title"] if meta
    end

    def featured?
      !!(meta["featured"] if meta)
    end
    alias_method :featured, :featured?

    # The license body (e.g., contents - frontmatter)
    def body
      @body ||= parts[2] if parts[2]
    end
    alias_method :to_s, :body
    alias_method :text, :body

    # License body with all whitespace replaced with a single space
    def body_normalized
      @content_normalized ||= body.to_s.downcase.gsub(/\s+/, " ").strip
    end

    # Git-computed hash signature for the license file
    def hashsig
      @hashsig ||= Rugged::Blob::HashSignature.new(
        body, Rugged::Blob::HashSignature::WHITESPACE_SMART)
    rescue Rugged::InvalidError
      nil
    end

    def inspect
      "#<Licensee::License key=\"#{key}\" name=\"#{name}\">"
    end

    def url
      URI.join(Licensee::DOMAIN, meta["permalink"]).to_s
    end

    private

    def parts
      @parts ||= content.match(/^(---\n.*\n---\n+)?(.*)/m).to_a
    end
  end
end
