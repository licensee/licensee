class Licensee
  class Project
    attr_reader :repository

    # Array of file names to look for potential license files, in order
    LICENSE_FILENAMES = %w[
      LICENSE
      LICENSE.txt
      LICENSE.md
      UNLICENSE
      COPYING
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
      license_blob = commit.tree.each_blob { |blob| break blob if LICENSE_FILENAMES.include? blob[:name] }

      @license_file = if license_blob
        LicenseFile.new(@repository.lookup(license_blob[:oid]))
      end
    end

    # Returns the matching Licensee::License instance if a license can be detected
    def license
      @license ||= license_file.match if license_file
    end
  end
end
