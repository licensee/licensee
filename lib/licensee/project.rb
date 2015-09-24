class Licensee
  class Project
    MAX_LICENSE_SIZE = 64 * 1024

    class << self
      def license_score(filename)
        return 1.0 if filename =~ /\A(un)?licen[sc]e\z/i
        return 0.9 if filename =~ /\A(un)?licen[sc]e\.(md|markdown|txt)\z/i
        return 0.8 if filename =~ /\Acopy(ing|right)(\.[^.]+)?\z/i
        return 0.7 if filename =~ /\A(un)?licen[sc]e\.[^.]+\z/i
        return 0.5 if filename =~ /licen[sc]e/i
        return 0.0
      end

      def package_score(filename)
        return 1.0  if filename =~ /[a-zA-Z0-9\-_]+\.gemspec/
        return 1.0  if filename =~ /package\.json/
        return 0.75 if filename =~ /bower.json/
        return 0.0
      end
    end

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
        if file = find_blob { |name| self.class.license_score(name) }
          data = load_blob_data(file[:oid])
          Project::LicenseFile.new(data, file[:name])
        end
      end
    end

    def package_file
      return unless detect_packages?
      return @package_file if defined? @package_file
      @package_file = begin
        if file = find_blob { |name| self.class.package_score(name) }
          data = load_blob_data(file[:oid])
          Project::PackageInfo.new(data, file[:name])
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
