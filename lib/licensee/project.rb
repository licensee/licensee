class Licensee
  class Project

    attr_reader :base_path

    def initialize(base_path)
      raise "Invalid path" unless File.directory?(base_path)
      @base_path = base_path
    end

    def path_exists?(path)
      File.exists? File.expand_path path, base_path
    end

    def license_file
      @license_file ||= Licensee::PATHS.find { |path| path_exists?(path) }
    end

    def license_file_path
      @license_file_path ||= File.expand_path license_file, base_path if license_file
    end

    def license_contents
      @license_contents ||= File.open(license_file_path).read if license_file
    end

    def length_delta(license)
      (license_contents.length - license.length).abs
    end

    def licenses_sorted
      Licensee.licenses.clone.sort_by { |l| length_delta(l.body) }
    end

    def matches
      return [] unless license_contents
      @matches ||= begin
        licenses_sorted.each do |license|
          license.match = 1 - percent_changed(license_contents, license.body).abs
        end
        licenses_sorted.sort_by { |l| l.match }.select { |l| l.match > 0}.reverse
      end
    end

    def license
      matches.first if matches
    end

    def percent_changed(unknown, known)
      Levenshtein.distance(unknown, known).to_f / unknown.length.to_f
    end
  end
end
