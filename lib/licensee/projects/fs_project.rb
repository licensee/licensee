# frozen_string_literal: true

# Filesystem-based project
#
# Analyze a folder on the filesystem for license information
#
# Project files for this project type will contain the following keys:
#  :name - the relative file name
#  :dir  - the directory path containing the file
module Licensee
  module Projects
    class FSProject < Licensee::Projects::Project
      def initialize(path, **args)
        @path = path
        @raw_root = args.delete(:search_root)

        raise 'Search root must be the project path directory or its ancestor' unless valid_search_root?

        super(**args)
      end

      private

      # Returns an array of hashes representing the project's files.
      # Hashes will have the the following keys:
      #  :name - the relative file name
      #  :dir  - the directory path containing the file
      def files
        @files ||= search_directories.flat_map do |dir|
          relative_dir = Pathname.new(dir).relative_path_from(dir_path).to_s

          glob = File.join(dir, '*').tr('\\', '/')
          Dir.glob(glob, File::FNM_DOTMATCH).map do |file|
            next unless File.file?(file)

            { name: File.basename(file), dir: relative_dir }
          end.compact
        end
      end

      # Retrieve a file's content from disk, enforcing encoding
      #
      # file - the file hash, with the :name key as the file's relative path
      #
      # Returns the file contents as a string
      def load_file(file)
        content = File.read dir_path.join(file[:dir], file[:name])
        content.force_encoding(ProjectFiles::ProjectFile::ENCODING)

        return content if content.valid_encoding?

        content.encode(ProjectFiles::ProjectFile::ENCODING, **ProjectFiles::ProjectFile::ENCODING_OPTIONS)
      end

      # Returns true if @dir is @root or it's descendant
      def valid_search_root?
        dir_path.fnmatch?(search_root.to_s) || dir_path.fnmatch?(search_root.join('**').to_s)
      end

      # Returns the set of unique paths to search for project files
      # in order from @dir -> @root
      def search_directories
        search_enumerator.map(&:to_path)
                         .push(search_root.to_s) # ensure root is included in the search
                         .uniq # don't include the root twice if @dir == @root
      end

      # Enumerates all directories to search, from @dir to @root
      def search_enumerator
        Enumerator.new do |yielder|
          dir_path.relative_path_from(search_root).ascend do |relative|
            yielder.yield search_root.join(relative)
          end
        end
      end

      # Returns the project's root directory
      def dir_path
        @dir_path ||= begin
          path = File.file?(@path) ? File.dirname(@path) : @path
          Pathname.new(path).expand_path
        end
      end

      # Search up until this directory to find files
      # Search root must be the project path directory or its ancestor
      def search_root
        @search_root ||= Pathname.new(@raw_root || dir_path).expand_path
      end
    end
  end
end
