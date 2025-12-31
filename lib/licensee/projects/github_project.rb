# frozen_string_literal: true

# GitHub project
#
# Analyses a remote GitHub repository for license information
#
# Only the root directory of a repository will be scanned because every
# `#load_file(..)` call incurs a separate API request.

autoload :Octokit, 'octokit'

module Licensee
  module Projects
    # Scans a remote GitHub repository for license-related files (via API).
    class GitHubProject < Licensee::Projects::Project
      attr_reader :ref, :repo

      # If there's any trailing data (e.g. `.git`) this pattern will ignore it:
      # we're going to use the API rather than clone the repo.
      GITHUB_REPO_PATTERN =
        %r{https://github.com/([^/]+/([^/]+(?=\.git)|[^/]+)).*}

      class RepoNotFound < StandardError; end

      def initialize(github_url, ref: nil, **args)
        @repo = github_url[GITHUB_REPO_PATTERN, 1]
        raise ArgumentError, "Not a github URL: #{github_url}" unless @repo

        @ref = ref

        super(**args)
      end

      private

      # Returns an array of hashes representing the project's files.
      # Hashes will have the the following keys:
      #  :name - the relative file name
      #  :oid  - the file's OID
      #  :dir  - the directory path containing the file
      def files
        return @files if defined? @files

        @files = load_files_with_license_dir
        raise RepoNotFound, repo_not_found_message if @files.empty?

        @files
      end

      def query_params
        return { ref: @ref } unless @ref.nil?

        {}
      end

      def load_file(file)
        client.contents(@repo, path:   file[:path],
                               accept: 'application/vnd.github.v3.raw',
                               query:  query_params).to_s
      end

      def dir_files(path = nil)
        path = path.gsub('./', '') if path
        files = client.contents(@repo, path: path, query: query_params)
        files = files.select { |data| data[:type] == 'file' }
        files.each { |data| data[:dir] = File.dirname(data[:path]) }
        files.map(&:to_h)
      end

      def load_files_with_license_dir
        base_files = dir_files
        license_dir_files = begin
          dir_files('LICENSES')
        rescue Octokit::NotFound
          []
        end

        base_files + license_dir_files
      rescue Octokit::NotFound
        []
      end

      def repo_not_found_message
        "Could not load GitHub repo #{repo}, it may be private or deleted"
      end

      def client
        @client ||= Octokit::Client.new access_token: access_token
      end

      def access_token
        ENV.fetch('OCTOKIT_ACCESS_TOKEN', nil)
      end
    end
  end
end
