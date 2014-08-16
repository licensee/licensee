require 'levenshtein-ffi'
require 'yaml'
require 'diffy'

require_relative "licensee/file_finder"
require_relative "licensee/license"
require_relative "licensee/licenses"
require_relative "licensee/license_file"
require_relative "licensee/readme"
require_relative "licensee/project"

class Licensee

  STRICT = false

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
end
