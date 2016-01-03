require 'rugged'

module Licensee
  private
  class Project
    def initialize(detect_packages)
      @detect_packages = detect_packages
    end

    def detect_packages?
      @detect_packages
    end

    # Returns the matching Licensee::License instance if a license can be detected
    def license
      @license ||= matched_file && matched_file.license
    end

    def matched_file
      @matched_file ||= (license_file || package_file)
    end

    def license_file
      return @license_file if defined? @license_file
      @license_file = begin
        content, name = find_file { |name| LicenseFile.name_score(name) }
        if content && name
          LicenseFile.new(content, name)
        end
      end
    end

    def package_file
      return unless detect_packages?
      return @package_file if defined? @package_file
      @package_file = begin
        content, name = find_file { |name| PackageInfo.name_score(name) }
        if content && name
          PackageInfo.new(content, name)
        end
      end
    end
  end
end
