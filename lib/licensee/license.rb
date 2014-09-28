class Licensee
  class License

    attr_reader :name
    attr_accessor :match

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
      @body ||= raw_body.downcase.gsub(/\s+/, "")
    end
    alias_method :to_s, :body

    def raw_body
      @raw_body ||= parts[2]
    end

    def inspect
      s = "#<Licensee::License name=\"#{name}\""
      s += " match=#{match}" if match
      s += ">"
      s
    end
  end
end
