require 'pathname'

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
      unless valid_search_root?
        raise 'Search root must the FSProject path directory or its ancestory'
      end

      super(**args)
    end

    private

    # Returns an array of hashes representing the project's files.
    # Hashes will have the the following keys:
    #  :name - the file name and extension
    #  :dir  - the path to the directory
    def files
      search_directories.flat_map do |dir|
        Dir.glob(::File.join(dir, @pattern).tr('\\', '/')).map do |file|
          next unless ::File.file?(file)
          { name: ::File.basename(file), dir: dir }
        end.compact
      end
    end

    # Retrieve a file's content from disk
    #
    # file - the file hash, with the :name key as the file's relative path
    #
    # Returns the file contents as a string
    def load_file(file)
      ::File.read(::File.join(file[:dir], file[:name]))
    end

    # Returns true if @dir is @root or it's descendant
    def valid_search_root?
      dir = Pathname.new(@dir)
      dir.fnmatch?(@root) || dir.fnmatch?(::File.join(@root, '**'))
    end

    # Enumerates all directories to search, from @dir to @root
    def search_directories
      root = Pathname.new(@root)
      Pathname.new(@dir)
              .relative_path_from(root)
              .ascend # search from dir to root
              .map { |rel| root.join(rel).to_path }
              .push(@root) # ensure root is included in the search
              .uniq # don't include the root twice if @dir == @root
    end
  end
end
