class Licensee
  class FilesystemRepository
    def initialize(path)
      @path = path
    end

    def last_commit() self end

    def tree
      return to_enum(__method__) unless block_given?
      Dir.entries(@path).each do |name|
        filename = ::File.join @path, name
        next if ::File.directory? filename
        yield(:name => name, :type => :blob, :oid => filename)
      end
    end

    def lookup(filename)
      Blob.new ::File.read(filename)
    end

    Blob = Struct.new(:content) do
      def size
        content.size
      end

      def similarity(other)
        self.hashsig ? Rugged::Blob::HashSignature.compare(self.hashsig, other) : 0
      end

      def hashsig(options = 0)
        @hashsig ||= Rugged::Blob::HashSignature.new(content, options)
      rescue Rugged::InvalidError
        nil
      end
    end
  end
end
