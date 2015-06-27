class Licensee
  class Project
    attr_reader :repository

    # Array of file names to look for potential license files, in order
    # Filenames should be lower case as candidates are downcased before comparison
    LICENSE_FILENAMES = %w[
      license
      license.txt
      license.md
      unlicense
      copying
      copyright
    ]

    # Initializes a new project
    #
    # path_or_repo path to git repo or Rugged::Repository instance
    # revsion - revision ref, if any
    def initialize(path_or_repo, revision = nil)
      if path_or_repo.kind_of? Rugged::Repository
        @repository = path_or_repo
      else
        begin
          @repository = Rugged::Repository.new(path_or_repo)
        rescue Rugged::RepositoryError
          if revision
            raise
          else
            @repository = FilesystemRepository.new(path_or_repo)
          end
        end
      end

      @revision = revision
    end

    # Returns an instance of Licensee::LicenseFile if there's a license file detected
    def license_file
      @license_file ||= LicenseFile.new(license_blob, :path => license_path) if license_blob
    end

    # Returns the matching Licensee::License instance if a license can be detected
    def license
      @license ||= license_file.match if license_file
    end

    private

    def commit
      @revision ? @repository.lookup(@revision) : @repository.last_commit
    end

    def tree
      commit.tree.select { |blob| blob[:type] == :blob }
    end

    # Detects the license file, if any
    # Returns the blob hash as detected in the tree
    def license_hash
      # Prefer an exact match to one of our known file names
      license_hash = tree.find { |blob| LICENSE_FILENAMES.include? blob[:name].downcase }

      # Fall back to the first file in the project root that has the word license in it
      license_hash || tree.find { |blob| blob[:name] =~ /licen(s|c)e/i }
    end

    def license_blob
      @repository.lookup(license_hash[:oid]) if license_hash
    end

    def license_path
      license_hash[:name] if license_hash
    end
  end
end
