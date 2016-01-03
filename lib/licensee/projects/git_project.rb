# Git-based project
#
# analyze a given git repository for license information
class Licensee
  class GitProject < Licensee::Project
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
end
