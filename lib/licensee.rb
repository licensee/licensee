require 'yaml'
require 'rugged'
require 'levenshtein'

require_relative "licensee/license"
require_relative "licensee/licenses"
require_relative "licensee/license_file"
require_relative "licensee/project"
require_relative "licensee/matcher"
require_relative "licensee/matchers/exact_matcher"
require_relative "licensee/matchers/git_matcher"
require_relative "licensee/matchers/levenshtein_matcher"

class Licensee
  CONFIDENCE_THRESHOLD = 90

  class << self

    def licenses
      Licensee::Licenses.list
    end

    def license(path)
      Licensee::Project.new(path).license
    end

    def matchers
      [Licensee::ExactMatcher, Licensee::GitMatcher, Licensee::LevenshteinMatcher]
    end
  end
end
