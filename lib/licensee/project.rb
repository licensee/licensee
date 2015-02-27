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

    # Detects the license file, if any
    # Returns a Licensee::LicenseFile instance
    def license_file
      return @license_file if defined? @license_file

      commit = @revision ? @repository.lookup(@revision) : @repository.last_commit

      # Prefer an exact match to one of our known file names
      license_blob = commit.tree.find { |blob| LICENSE_FILENAMES.include? blob[:name].downcase }

      # Fall back to the first file in the project root that has the word license in it
      license_blob = commit.tree.find { |blob| blob[:name] =~ /license/i } unless license_blob

      @license_file = LicenseFile.new(@repository.lookup(license_blob[:oid])) if license_blob
    end

    # Returns the matching Licensee::License instance if a license can be detected
    def license
      @license ||= license_file.match if license_file
    end
  end
end
