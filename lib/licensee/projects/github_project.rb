# GitHub project
#
# Analyses a remote GitHub repository for license information
#
# Only the root directory of a repository will be scanned because every
# `#load_file(..)` call incurs a separate API request.

require 'octokit'

module Licensee
  module Projects
    class GitHubProject < Licensee::Projects::Project
      # If there's any trailing data (e.g. `.git`) this pattern will ignore it:
      # we're going to use the API rather than clone the repo.
      GITHUB_REPO_PATTERN =
        %r{https://github.com/([^\/]+\/([^\/]+(?=\.git)|[^\/]+)).*}

      class RepoNotFound < StandardError; end

      def initialize(github_url, **args)
        @repo = github_url[GITHUB_REPO_PATTERN, 1]
        raise ArgumentError, "Not a github URL: #{github_url}" unless @repo
        super(**args)
      end

      attr_reader :repo

      private

      def files
        @files ||= contents.map { |data| { name: data[:name], dir: '/' } }
      rescue Octokit::NotFound
        raise RepoNotFound,
              "Could not load GitHub repo #{repo}, it may be private or deleted"
      end

      def load_file(file)
        Octokit.contents(@repo, path:   file[:name],
                                accept: 'application/vnd.github.v3.raw')
      end

      def contents
        Octokit.contents(@repo).select { |data| data[:type] == 'file' }
      end
    end
  end
end
