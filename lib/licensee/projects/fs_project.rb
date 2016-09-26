# Filesystem-based project
#
# Analyze a folder on the filesystem for license information
module Licensee
  class FSProject < Project
    attr_reader :path

    def initialize(path, **args)
      @path = path
      super(**args)
    end

    private

    # Returns an array of hashes representing the project's files.
    # Hashes will have the :name key, with the relative path to the file
    def files
      files = []

      if ::File.file?(path)
        pattern = ::File.basename(path)
        @path = ::File.dirname(path)
      else
        pattern = '*'
      end

      Dir.glob(::File.join(path, pattern)) do |file|
        next unless ::File.file?(file)
        files.push(name: ::File.basename(file))
      end

      files
    end

    # Retrieve a file's content from disk
    #
    # file - the file hash, with the :name key as the file's relative path
    #
    # Returns the fiel contents as a string
    def load_file(file)
      ::File.read(::File.join(path, file[:name]))
    end
  end
end
