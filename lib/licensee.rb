require_relative "licensee/version"
require_relative "licensee/content_helper"
require_relative "licensee/license"

# Projects
require_relative "licensee/project"
require_relative "licensee/projects/git_project"
require_relative "licensee/projects/fs_project"

# Project files
require_relative "licensee/project_file"
require_relative "licensee/project_files/license_file"
require_relative "licensee/project_files/package_info"
require_relative "licensee/project_files/readme"

# Matchers
require_relative "licensee/matchers/exact_matcher"
require_relative "licensee/matchers/copyright_matcher"
require_relative "licensee/matchers/dice_matcher"
require_relative "licensee/matchers/package_matcher"
require_relative "licensee/matchers/gemspec_matcher"
require_relative "licensee/matchers/npm_bower_matcher"

module Licensee
  # Over which percent is a match considered a match by default
  CONFIDENCE_THRESHOLD = 90

  # Base domain from which to build license URLs
  DOMAIN = "http://choosealicense.com"

  class << self
    attr_writer :confidence_threshold

    # Returns an array of Licensee::License instances
    def licenses(options={})
      Licensee::License.all(options)
    end

    # Returns the license for a given path
    def license(path)
      Licensee.project(path).license
    end

    def project(path)
      begin
        Licensee::GitProject.new(path)
      rescue Licensee::GitProject::InvalidRepository
        Licensee::FSProject.new(path)
      end
    end

    def confidence_threshold
      @confidence_threshold ||= CONFIDENCE_THRESHOLD
    end
  end
end
