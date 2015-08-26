class Licensee
  class InvalidLicense < ArgumentError; end
  class License

    def self.all
      Licensee::licenses
    end

    attr_reader :key

    YAML_DEFAULTS = {
      "featured" => false,
      "hidden"   => false,
      "variant"  => false
    }

    HIDDEN_LICENSES = %w[other no-license]

    def initialize(key)
      @key=key.downcase
    end

    # Path to vendored license file on disk
    def path
      @path ||= ::File.expand_path "#{@key}.txt", Licensee::Licenses.base
    end

    # Raw content of license file, including YAML front matter
    def content
      @content ||= if ::File.exists?(path)
        ::File.open(path).read
      elsif key == "other" # A pseudo-license with no content
        nil
      else
        raise Licensee::InvalidLicense, "'#{key}' is not a valid license key"
      end
    end

    # License metadata from YAML front matter
    def meta
      @meta ||= if parts && parts[1]
        if YAML.respond_to? :safe_load
          meta = YAML.safe_load(parts[1])
        else
          meta = YAML.load(parts[1])
        end
        YAML_DEFAULTS.merge(meta)
      end
    end

    # Returns the human-readable license name
    def name
      meta.nil? ? key.capitalize : meta["title"]
    end

    def featured?
      !!(meta["featured"] if meta)
    end
    alias_method :featured, :featured?

    def hidden?
      return true if HIDDEN_LICENSES.include?(key)
      !!(meta["hidden"] if meta)
    end

    # The license body (e.g., contents - frontmatter)
    def body
      @body ||= parts[2] if parts && parts[2]
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
      URI.join(Licensee::DOMAIN, "/licenses/#{key}/").to_s
    end

    private

    def parts
      @parts ||= content.match(/\A(---\n.*\n---\n+)?(.*)/m).to_a if content
    end
  end
end
