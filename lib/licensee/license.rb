class Licensee
  class InvalidLicense < ArgumentError; end
  class License

    class << self
      def all(options={})
        @all ||= keys.map { |key| self.new(key) }
        options[:hidden] ? @all : @all.reject { |l| l.hidden? }
      end

      def keys
        @keys ||= license_files.map { |l| File.basename(l, ".txt").downcase } + ["other"]
      end

      def find(key, options={})
        options = {:hidden => true}.merge(options)
        key = key.downcase
        all(options).find { |license| license.key == key }
      end
      alias_method :[], :find
      alias_method :find_by_key, :find

      def license_dir
        File.expand_path "../../vendor/choosealicense.com/_licenses", File.dirname(__FILE__)
      end

      def license_files
        @license_files ||= Dir.glob("#{license_dir}/*.txt")
      end
    end

    attr_reader :key

    YAML_DEFAULTS = {
      "featured" => false,
      "hidden"   => false,
      "variant"  => false
    }

    HIDDEN_LICENSES = %w[other no-license]

    # Licenses that technically contain the license name or nickname
    # But we are so short that GitMatcher may not catch if rewrapped
    BODY_INCLUDES_WHITELIST = %w[mit]

    include Licensee::ContentHelper

    def initialize(key)
      @key=key.downcase
    end

    # Path to vendored license file on disk
    def path
      @path ||= File.expand_path "#{@key}.txt", Licensee::License.license_dir
    end

    # Raw content of license file, including YAML front matter
    def content
      @content ||= if File.exists?(path)
        File.open(path).read
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

    def nickname
      meta["nickname"] if meta
    end

    def name_without_version
      /(.+?)(( v?\d\.\d)|$)/.match(name)[1]
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
      @body_normalized ||= normalize_content(body)
    end

    # Git-computed hash signature for the license file
    def hashsig
      @hashsig ||= Rugged::Blob::HashSignature.new(
        body, Rugged::Blob::HashSignature::WHITESPACE_SMART) unless body.nil?
    rescue Rugged::InvalidError
      nil
    end

    def inspect
      "#<Licensee::License key=\"#{key}\" name=\"#{name}\">"
    end

    def url
      URI.join(Licensee::DOMAIN, "/licenses/#{key}/").to_s
    end

    def ==(other)
      other != nil && key == other.key
    end

    def body_includes_name?
      return false if BODY_INCLUDES_WHITELIST.include?(key)
      @body_includes_name ||= body_normalized.include?(name_without_version.downcase)
    end

    def body_includes_nickname?
      return false if BODY_INCLUDES_WHITELIST.include?(key)
      @body_includes_nickname ||= !!(nickname && body_normalized.include?(nickname.downcase))
    end

    private

    def parts
      @parts ||= content.match(/\A(---\n.*\n---\n+)?(.*)/m).to_a if content
    end
  end
end
