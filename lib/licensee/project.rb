require 'rugged'

module Licensee
  class Project
    attr_reader :detect_readme, :detect_packages
    alias detect_readme? detect_readme
    alias detect_packages? detect_packages

    def initialize(detect_packages: false, detect_readme: false)
      @detect_packages = detect_packages
      @detect_readme = detect_readme
    end

    # Returns the matching License instance if a license can be detected
    def license
      return @license if defined? @license
      @license = if licenses.count == 1 || lgpl?
        licenses.first
      end
    end

    # Returns an array of detected Licenses
    def licenses
      @licenses ||= matched_files.map(&:license).uniq
    end

    # Returns the ProjectFile used to determine the License
    def matched_file
      matched_files.first if matched_files.count == 1 || lgpl?
    end

    # Returns an array of matches LicenseFiles
    def matched_files
      @matched_files ||= [license_files, readme, package_file].flatten.compact.select(&:license)
    end

    # Returns the LicenseFile used to determine the License
    def license_file
      license_files.first if license_files.count == 1 || lgpl?
    end

    def license_files
      @license_files ||= begin
        return [] if files.empty? || files.nil?
        files = find_files { |n| LicenseFile.name_score(n) }
        files = files.map { |file| LicenseFile.new(load_file(file), file[:name]) }
        return files if files.empty? || !files.first.license

        # Special case LGPL, which actually lives in LICENSE.lesser, per the
        # license instructions. See https://git.io/viwyK
        if files.first && files.first.license && files.first.license.gpl?
          lesser = files.find_index { |l| l.lgpl? }
          files.unshift(files.delete_at(lesser)) if lesser
        end

        files
      end
    end

    def readme_file
      return unless detect_readme?
      return @readme if defined? @readme
      @readme = begin
        content, name = find_file { |n| Readme.name_score(n) }
        content = Readme.license_content(content)
        Readme.new(content, name) if content && name
      end
    end
    alias readme readme_file

    def package_file
      return unless detect_packages?
      return @package_file if defined? @package_file
      @package_file = begin
        content, name = find_file { |n| PackageInfo.name_score(n) }
        PackageInfo.new(content, name) if content && name
      end
    end

    private

    def lgpl?
      licenses.count == 2 && license_files[0].lgpl? && license_files[1].gpl?
    end

    # Given a block, passes each filename to that block, and expects a numeric
    # score in response. Returns an array of all files with a score > 0,
    # sorted by file score descending
    def find_files
      return [] if files.empty? || files.nil?
      found = files.each { |file| file[:score] = yield(file[:name]) }
      found.select! { |file| file[:score] > 0 }
      found.sort { |a, b| b[:score] <=> a[:score] }
    end

    # Given a block, passes each filename to that block, and expects a numeric
    # score in response. Returns a hash representing the top scoring file
    # or nil, if no file scored > 0
    def find_file(&block)
      return if files.empty? || files.nil?
      file = find_files(&block).first
      [load_file(file), file[:name]] if file
    end

    def license_from_file(&block)
      content, name = find_file(&block)
      LicenseFile.new(content, name) if content && name
    end
  end
end
