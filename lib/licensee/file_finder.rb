class Licensee
  class FileFinder

    FILENAMES = %w[]

    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def contents
      @contents ||= File.open(path).read
    end
    alias_method :to_s, :contents
    alias_method :content, :contents

    def self.find(base_path)
      raise "Invalid directory" unless File.directory?(base_path)
      file = self::FILENAMES.find { |file| File.exists? File.expand_path(file, base_path) }
      new(File.expand_path(file, base_path)) if file
    end
  end
end
