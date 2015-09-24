require 'rugged'

class Licensee
  class Project
    MAX_LICENSE_SIZE = 64 * 1024

    attr_reader :repository, :revision

    # Initializes a new project
    #
    # path_or_repo path to git repo or Rugged::Repository instance
    # revsion - revision ref, if any
    def initialize(repo, revision: nil, detect_packages: false)
      if repo.kind_of? Rugged::Repository
        @repository = repo
      else
        @repository = Rugged::Repository.new(repo)
      end

      @revision = revision
      @detect_packages = detect_packages
    end

    def detect_packages?
      @detect_packages
    end

    # Returns the matching Licensee::License instance if a license can be detected
    def license
      @license ||= matched_file && matched_file.license
    end

    def matched_file
      @matched_file ||= (license_file || package_file)
    end

    def license_file
      return @license_file if defined? @license_file
      @license_file = begin
        if file = find_blob { |name| LicenseFile.name_score(name) }
          data = load_blob_data(file[:oid])
          LicenseFile.new(data, file[:name])
        end
      end
    end

    def package_file
      return unless detect_packages?
      return @package_file if defined? @package_file
      @package_file = begin
        if file = find_blob { |name| PackageInfo.name_score(name) }
          data = load_blob_data(file[:oid])
          PackageInfo.new(data, file[:name])
        end
      end
    end

    private
    def commit
      @commit ||= revision ? repository.lookup(revision) : repository.last_commit
    end

    def load_blob_data(oid)
      data, _ = Rugged::Blob.to_buffer(repository, oid, MAX_LICENSE_SIZE)
      data
    end

    def find_blob
      commit.tree.map do |entry|
        next unless entry[:type] == :blob
        if (score = yield entry[:name]) > 0
          { :name => entry[:name], :oid => entry[:oid], :score => score }
        end
      end.compact.sort { |a, b| b[:score] <=> a[:score] }.first
    end
  end
end
