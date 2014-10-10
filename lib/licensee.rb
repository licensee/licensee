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

  # Over watch percent is a match considered a match
  CONFIDENCE_THRESHOLD = 90

  class << self

    # Returns an array of Licensee::License instances
    def licenses
      @licenses ||= Licensee::Licenses.list
    end

    # Returns the license for a given git repo
    def license(path)
      Licensee::Project.new(path).license
    end

    # Diffs the project license and the known license
    def diff(path)
      Licensee::Project.new(path).license_file.diff
    end

    # Array of matchers to use, in order of preference
    # The order should be decending order of anticipated speed to match
    def matchers
      [Licensee::ExactMatcher, Licensee::GitMatcher, Licensee::LevenshteinMatcher]
    end
  end
end
