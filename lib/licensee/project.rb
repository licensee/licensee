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

    def readme_file
      @readme_file ||= Licensee::Readme.find(base_path)
    end

  end
end
