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
      @root = args.delete(:search_root) || @dir
      super(**args)
    end

    private

    # Returns an array of hashes representing the project's files.
    # Hashes will have the :name key, with the relative path to the file
    def files
      dir = @dir
      files = []

      while search_directory?(dir)
        Dir.glob(::File.join(dir, @pattern).tr('\\', '/')) do |file|
          next unless ::File.file?(file)
          files.push(name: ::File.basename(file))
        end

        dir = ::File.expand_path('..', dir)
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

    # Returns whether a directory should be searched for license files
    #
    # dir - a directory path string
    #
    # Returns true if the directory path is a descendant of the search root
    def search_directory?(dir)
      dir_parts = ::File.expand_path(dir).split(::File::SEPARATOR)
      @root_parts ||= ::File.expand_path(@root).split(::File::SEPARATOR)

      return false if dir_parts.length < @root_parts.length

      dir_parts[0..@root_parts.length - 1] == @root_parts
    end
  end
end
