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
    class GitHubProject < Licensee::Projects::Project
      # If there's any trailing data (e.g. `.git`) this pattern will ignore it:
      # we're going to use the API rather than clone the repo.
      GITHUB_REPO_PATTERN =
        %r{https://github.com/([^/]+/([^/]+(?=\.git)|[^/]+)).*}.freeze

      class RepoNotFound < StandardError; end

      def initialize(github_url, **args)
        @repo = github_url[GITHUB_REPO_PATTERN, 1]
        raise ArgumentError, "Not a github URL: #{github_url}" unless @repo

        super(**args)
      end

      attr_reader :repo

      private

      def files
        return @files if defined? @files_from_tree

        @files = dir_files
        return @files unless @files.empty?

        msg = "Could not load GitHub repo #{repo}, it may be private or deleted"
        raise RepoNotFound, msg
      end

      def load_file(file)
        client.contents(@repo, path:   file[:path],
                               accept: 'application/vnd.github.v3.raw').to_s
      end

      def dir_files(path = nil)
        path = path.gsub('./', '') if path
        files = client.contents(@repo, path: path)
        files = files.select { |data| data[:type] == 'file' }
        files.each { |data| data[:dir] = File.dirname(data[:path]) }
        files.map(&:to_h)
      rescue Octokit::NotFound
        []
      end

      def client
        @client ||= Octokit::Client.new access_token: access_token
      end

      def access_token
        ENV['OCTOKIT_ACCESS_TOKEN']
      end
    end
  end
end
