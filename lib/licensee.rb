require 'fuzzystringmatch'
require 'yaml'
require 'diffy'
require 'parallel'

require_relative "licensee/license"
require_relative "licensee/licenses"
require_relative "licensee/license_file"
require_relative "licensee/project"

class Licensee

  CONFIDENCE_THRESHOLD = ".80".to_f

  def self.licenses
    Licensee::Licenses.list
  end

  def self.license(path)
    Licensee::Project.new(path).license
  end

  def self.matches(path)
    Licensee::Project.new(path).matches
  end

  def self.diff(path, options=nil)
    Licensee::Project.new(path).license_file.diff(options)
  end

  def self.matcher
    @matcher ||= FuzzyStringMatch::JaroWinkler.create( :native )
  end
end
