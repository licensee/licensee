class Licensee
  class License
    attr_reader :name

    def initialize(name)
      @name=name.downcase
    end

    def path
      @path ||= File.expand_path "#{@name}.txt", Licensee::Licenses.base
    end

    def content
      @content ||= File.open(path).read
    end

    def parts
      @parts ||= content.match(/^(---\n.*\n---)?(.*)/m).to_a
    end

    def meta
      @meta ||= front_matter = YAML.load(parts[1]) if parts[1]
    rescue
      nil
    end

    def length
      @length ||= body.length
    end

    def body
      @body ||= parts[2]
    end
    alias_method :to_s, :body
    alias_method :text, :body

    def hashsig
      @hashsig ||= Rugged::Blob::HashSignature.new(
        body, Rugged::Blob::HashSignature::WHITESPACE_SMART)
    end

    def inspect
      "#<Licensee::License name=\"#{name}\">"
    end
  end
end
