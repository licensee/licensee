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
        @repository = Rugged::Repository.new(path_or_repo)
      end

      @revision = revision
    end

    # Returns an instance of Licensee::LicenseFile if there's a license file detected
    def license_file
      @license_file ||= LicenseFile.new(@repository.lookup(license_blob[:oid])) if license_blob
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
    def license_blob
      # Prefer an exact match to one of our known file names
      license_blob = tree.find { |blob| LICENSE_FILENAMES.include? blob[:name].downcase }

      # Fall back to the first file in the project root that has the word license in it
      license_blob || tree.find { |blob| blob[:name] =~ /licen(s|c)e/i }
    end
  end
end
