require 'yaml'
require 'rugged'

require_relative "licensee/license"
require_relative "licensee/licenses"
require_relative "licensee/license_file"
require_relative "licensee/project"

class Licensee
  CONFIDENCE_THRESHOLD = 90

  def self.licenses
    Licensee::Licenses.list
  end

  def self.license(path)
    Licensee::Project.new(path).license
  end
end
