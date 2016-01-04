require 'rugged'

class Licensee
  private
  class Project
    def initialize(detect_packages: false, detect_readme: false)
      @detect_packages = detect_packages
      @detect_readme = detect_readme
    end

    def detect_readme?
      @detect_readme
    end

    def detect_packages?
      @detect_packages
    end

    # Returns the matching Licensee::License instance if a license can be detected
    def license
      @license ||= matched_file && matched_file.license
    end

    def matched_file
      @matched_file ||= (license_file || readme || package_file)
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

    def readme
      return unless detect_readme?
      return @readme if defined? @readme
      @readme = begin
        content, name = find_file { |name| Readme.name_score(name) }
        content = Readme.license_content(content)
        if content && name
          Readme.new(content, name)
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
