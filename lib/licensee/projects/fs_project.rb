# Filesystem-based project
#
# Analyze a folder on the filesystem for license information
module Licensee
  class FSProject < Project
    def initialize(path, **args)
      if ::File.file?(path)
        @pattern = ::File.basename(path)
        @dir = ::File.dirname(path)
      else
        @pattern = '*'
        @dir = path
      end
      super(**args)
    end

    private

    # Returns an array of hashes representing the project's files.
    # Hashes will have the :name key, with the relative path to the file
    def files
      files = []

      Dir.glob(::File.join(@dir, @pattern).gsub('\\', '/')) do |file|
        next unless ::File.file?(file)
        files.push(name: ::File.basename(file))
      end

      files
    end

    # Retrieve a file's content from disk
    #
    # file - the file hash, with the :name key as the file's relative path
    #
    # Returns the file contents as a string
    def load_file(file)
      ::File.read(::File.join(@dir, file[:name]))
    end
  end
end
