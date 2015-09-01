require 'uri'
require 'yaml'
require 'rugged'
require 'levenshtein'

require_relative "licensee/version"
require_relative "licensee/content_helper"
require_relative "licensee/license"
require_relative "licensee/project"
require_relative "licensee/project_file"
require_relative "licensee/filesystem_repository"
require_relative "licensee/matcher"
require_relative "licensee/matchers/exact_matcher"
require_relative "licensee/matchers/copyright_matcher"
require_relative "licensee/matchers/git_matcher"
require_relative "licensee/matchers/levenshtein_matcher"
require_relative "licensee/matchers/package_matcher"
require_relative "licensee/matchers/gemspec_matcher"
require_relative "licensee/matchers/npm_bower_matcher"

class Licensee

  # Over which percent is a match considered a match by default
  CONFIDENCE_THRESHOLD = 90

  # Base domain from which to build license URLs
  DOMAIN = "http://choosealicense.com"

  class << self

    attr_writer :confidence_threshold, :package_manager_files

    # Returns an array of Licensee::License instances
    def licenses(options={})
      Licensee::License.all(options)
    end

    # Returns the license for a given git repo
    def license(path)
      Licensee::Project.new(path).license
    end

    # Array of matchers to use, in order of preference
    # The order should be decending order of anticipated speed to match
    def matchers
      matchers = [
        Licensee::CopyrightMatcher,
        Licensee::ExactMatcher,
        Licensee::GitMatcher,
        Licensee::LevenshteinMatcher,
        Licensee::GemspecMatcher,
        Licensee::NpmBowerMatcher
      ]
      matchers.reject! { |m| m.package_manager? } unless package_manager_files?
      matchers
    end

    def confidence_threshold
      @confidence_threshold ||= CONFIDENCE_THRESHOLD
    end

    def package_manager_files?
      @package_manager_files ||= false
    end
  end
end
