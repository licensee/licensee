require_relative 'licensee/version'
require 'rugged'

module Licensee
  autoload :ContentHelper, 'licensee/content_helper'
  autoload :License, 'licensee/license'
  autoload :Rule, 'licensee/rule'
  autoload :Project, 'licensee/project'
  autoload :FSProject, 'licensee/projects/fs_project'
  autoload :GitProject, 'licensee/projects/git_project'
  autoload :Matchers, 'licensee/matchers'

  # Over which percent is a match considered a match by default
  CONFIDENCE_THRESHOLD = 95

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
