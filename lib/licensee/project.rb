class Licensee
  class Project
    attr_reader :repository

    VALID_FILENAMES = %w[
      LICENSE
      LICENSE.txt
      LICENSE.md
      UNLICENSE
      COPYING
    ]

    def initialize(path_or_repo, revision = nil)
      if path_or_repo.kind_of? Rugged::Repository
        @repository = path_or_repo
      else
        @repository = Rugged::Repository.new(path_or_repo)
      end

      @revision = revision
    end

    def license_file
      return @license_file if defined? @license_file

      commit = @revision ? @repository.lookup(@revision) : @repository.last_commit
      license_blob = commit.tree.each_blob { |blob| break blob if VALID_FILENAMES.include? blob[:name] }


      @license_file = if license_blob
        LicenseFile.new(@repository.lookup(license_blob[:oid]))
      end
    end

    def matches
      @matches ||= license_file.matches if license_file
    end

    def license
      @license ||= license_file.match if license_file
    end
  end
end
