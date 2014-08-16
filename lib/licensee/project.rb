class Licensee
  class Project

    attr_reader :base_path

    def initialize(base_path)
      raise "Invalid directory" unless File.directory?(base_path)
      @base_path = File.expand_path(base_path)
    end

    def license_file
      @license_file ||= Licensee::LicenseFile.find(base_path)
    end

    def matches
      @matches ||= license_file.matches if license_file
    end

    def license
      @license ||= matches.first if matches
    end
  end
end
