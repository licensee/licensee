require_relative 'licensee/version'
require_relative 'licensee/content_helper'
require_relative 'licensee/license'
require_relative 'licensee/rule'

# Projects
require_relative 'licensee/project'
require_relative 'licensee/projects/git_project'
require_relative 'licensee/projects/fs_project'

# Project files
require_relative 'licensee/project_file'
require_relative 'licensee/project_files/license_file'
require_relative 'licensee/project_files/package_info'
require_relative 'licensee/project_files/readme'

# Matchers
require_relative 'licensee/matchers/exact_matcher'
require_relative 'licensee/matchers/copyright_matcher'
require_relative 'licensee/matchers/dice_matcher'
require_relative 'licensee/matchers/package_matcher'
require_relative 'licensee/matchers/gemspec_matcher'
require_relative 'licensee/matchers/npm_bower_matcher'
require_relative 'licensee/matchers/cran_matcher'
require_relative 'licensee/matchers/dist_zilla_matcher'

module Licensee
  # Over which percent is a match considered a match by default
  CONFIDENCE_THRESHOLD = 98

  # Base domain from which to build license URLs
  DOMAIN = 'http://choosealicense.com'.freeze

  class << self
    attr_writer :confidence_threshold

    # Returns an array of Licensee::License instances
    def licenses(options = {})
      Licensee::License.all(options)
    end

    # Returns the license for a given path
    def license(path)
      Licensee.project(path).license
    end

    def project(path, **args)
      Licensee::GitProject.new(path, args)
    rescue Licensee::GitProject::InvalidRepository
      Licensee::FSProject.new(path, args)
    end

    def confidence_threshold
      @confidence_threshold ||= CONFIDENCE_THRESHOLD
    end

    # Inverse of the confidence threshold, represented as a float
    # By default this will be 0.05
    def inverse_confidence_threshold
      @inverse ||= (1 - Licensee.confidence_threshold / 100.0).round(2)
    end
  end
end
