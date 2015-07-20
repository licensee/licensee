class Licensee
  class Project
    attr_reader :repository

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

    # Scores a given file as a potential license
    #
    # filename - (string) the name of the file to score
    #
    # Returns 1.0  if the file is definately a license file
    # Returns 0.75 if the file is probably a license file
    # Returns 0.5  if the file is likely a license file
    # Returns 0.0  if the file is definately not a license file
    def self.match_license_file(filename)
      return 1.0  if filename =~ /\A(un)?licen[sc]e(\.[^.]+)?\z/i
      return 0.75 if filename =~ /\Acopy(ing|right)(\.[^.]+)?\z/i
      return 0.5  if filename =~ /licen[sc]e/i
      return 0.0
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
      hashes = tree.map { |blob| [self.class.match_license_file(blob[:name]), blob] }
      hash = hashes.select { |hash| hash[0] > 0 }.sort_by { |hash| hash[0] }.last
      hash[1] if hash
    end

    def license_blob
      @repository.lookup(license_hash[:oid]) if license_hash
    end

    def license_path
      license_hash[:name] if license_hash
    end
  end
end
