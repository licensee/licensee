require 'levenshtein-ffi'
require 'yaml'

require_relative "licensee/file_finder"
require_relative "licensee/license"
require_relative "licensee/licenses"
require_relative "licensee/license_file"
require_relative "licensee/readme"
require_relative "licensee/project"

class Licensee
  def self.licenses
    Licensee::Licenses.list
  end
end
