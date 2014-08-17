class Licensee
  class LicenseFile

    FILENAMES = %w[
      LICENSE
      LICENSE.txt
      LICENSE.md
      UNLICENSE
    ]

    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def contents
      @contents ||= File.open(path).read
    end
    alias_method :to_s, :contents
    alias_method :content, :contents

    def self.find(base_path)
      raise "Invalid directory" unless File.directory?(base_path)
      file = self::FILENAMES.find { |file| File.exists? File.expand_path(file, base_path) }
      new(File.expand_path(file, base_path)) if file
    end

    def length
      @length ||= content.length
    end

    def length_delta(license)
      (length - license.length).abs
    end

    def potential_licenses
      @potential_licenses ||= Licensee::Licenses.list.clone.select { |l| length_delta(l) < length }
    end

    def licenses_sorted
      @licenses_sorted ||= potential_licenses.sort_by { |l| length_delta(l) }
    end

    def matches
      @matches ||= begin
        licenses_sorted.each { |l| l.match = 1 - percent_changed(l) }
        licenses_sorted.sort_by { |l| l.match }.select { |l| l.match > 0}.reverse
      end
    end

    def match
      @match ||= licenses_sorted.find do |license|
        confidence = 1 - percent_changed(license)
        next unless confidence >= Licensee::CONFIDENCE_THRESHOLD
        license.match = confidence
      end
    end

    def percent_changed(license)
      (Levenshtein.distance(content, license.body).to_f / content.length.to_f).abs
    end

    def diff(options=nil)
      Diffy::Diff.new(match.body, content).to_s(options)
    end

  end
end
