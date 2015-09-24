class Licensee
  class FilesystemRepository
    def initialize(path)
      @path = path
    end

    def last_commit() self end

    def tree
      return to_enum(__method__) unless block_given?
      Dir.entries(@path).each do |name|
        filename = File.join @path, name
        next if File.directory? filename
        yield(:name => name, :type => :blob, :oid => filename)
      end
    end

    def lookup(filename)
      File.read(filename)
    end
  end
end
