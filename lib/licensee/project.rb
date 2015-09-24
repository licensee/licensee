require 'rugged'

class Licensee
  private
  class Project
    def initialize(detect_packages)
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
        content, name = find_file { |name| LicenseFile.name_score(name) }
        if content && name
          LicenseFile.new(content, name)
        end
      end
    end

    def package_file
      return unless detect_packages?
      return @package_file if defined? @package_file
      @package_file = begin
        content, name = find_file { |name| PackageInfo.name_score(name) }
        if content && name 
          PackageInfo.new(content, name)
        end
      end
    end
  end

  public

  # Git-based project
  # 
  # analyze a given git repository for license information
  class GitProject < Project
    attr_reader :repository, :revision

    class InvalidRepository < ArgumentError; end

    def initialize(repo, revision: nil, detect_packages: false)
      if repo.kind_of? Rugged::Repository
        @repository = repo
      else
        @repository = Rugged::Repository.new(repo)
      end

      @revision = revision
      super(detect_packages)
    rescue Rugged::RepositoryError
      raise InvalidRepository
    end

    private
    def commit
      @commit ||= revision ? repository.lookup(revision) : repository.last_commit
    end

    MAX_LICENSE_SIZE = 64 * 1024

    def load_blob_data(oid)
      data, _ = Rugged::Blob.to_buffer(repository, oid, MAX_LICENSE_SIZE)
      data
    end

    def find_file
      files = commit.tree.map do |entry|
        next unless entry[:type] == :blob
        if (score = yield entry[:name]) > 0
          { :name => entry[:name], :oid => entry[:oid], :score => score }
        end
      end.compact

      return if files.empty?
      files.sort! { |a, b| b[:score] <=> a[:score] }

      f = files.first
      [load_blob_data(f[:oid]), f[:name]]
    end
  end

  # Filesystem-based project
  #
  # Analyze a folder on the filesystem for license information
  class FSProject < Project
    attr_reader :path

    def initialize(path, detect_packages: false)
      @path = path
      super(detect_packages)
    end

    private
    def find_file
      files = [] 

      Dir.foreach(path) do |file|
        next unless ::File.file?(::File.join(path, file))
        if (score = yield file) > 0
          files.push({ :name => file, :score => score })
        end
      end

      return if files.empty?
      files.sort! { |a, b| b[:score] <=> a[:score] }

      f = files.first
      [::File.read(::File.join(path, f[:name])), f[:name]]
    end
  end
end
