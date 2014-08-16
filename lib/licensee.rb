require 'levenshtein-ffi'
require 'yaml'
require_relative "licensee/license"
require_relative "licensee/project"

class Licensee

  PATHS = %w[
    LICENSE
    LICENSE.txt
    LICENSE.md
    UNLICENSE
  ]

  class << self

    def license_names
      @license_names ||= begin
        names = Dir.entries(license_base)
        names.map! { |l| File.basename(l, ".txt") }
        names.reject! { |l| l =~ /^\./ || l.nil? }
        names
      end
    end

    def licenses
      @licenses ||= begin
        licenses = []
        license_names.each { |name| licenses.push License.new(name) }
        licenses
      end
    end

    def license_base
      @license_base ||= File.expand_path "../vendor/choosealicense.com/licenses", File.dirname(__FILE__)
    end
  end
end
