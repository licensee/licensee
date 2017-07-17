# Git-based project
#
# Analyze a given (bare) Git repository for license information
#
# Project files for this project type will contain the following keys:
#  :name - the file's path relative to the repo root
#  :oid  - the file's OID
module Licensee
  module Projects
    class GitProject < Licensee::Projects::Project
      attr_reader :repository, :revision

      class InvalidRepository < ArgumentError; end

      def initialize(repo, revision: nil, **args)
        @repository = if repo.is_a? Rugged::Repository
          repo
        else
          Rugged::Repository.new(repo)
        end

        @revision = revision
        super(**args)
      rescue Rugged::OSError, Rugged::RepositoryError
        raise InvalidRepository
      end

      def close
        @repository.close
      end

      private

      def commit
        @commit ||= if revision
          repository.lookup(revision)
        else
          repository.last_commit
        end
      end

      MAX_LICENSE_SIZE = 64 * 1024

      # Retrieve a file's content from the Git database
      #
      # file - the file hash, including the file's OID
      #
      # Returns a string representing the file's contents
      def load_file(file)
        data, = Rugged::Blob.to_buffer(repository, file[:oid], MAX_LICENSE_SIZE)
        data
      end

      # Returns an array of hashes representing the project's files.
      # Hashes will have the the following keys:
      #  :name - the file's path relative to the repo root
      #  :oid  - the file's OID
      def files
        @files ||= commit.tree.map do |entry|
          next unless entry[:type] == :blob
          { name: entry[:name], oid: entry[:oid] }
        end.compact
      end
    end
  end
end
