class Licensee
  class LicenseFile < FileFinder

    FILENAMES = %w[
      LICENSE
      LICENSE.txt
      LICENSE.md
      UNLICENSE
    ]

    def length
      content.length
    end

    def length_delta(license)
      (length - license.length).abs
    end

    def potential_licenses
      Licensee::Licenses.list.clone.select { |l| length_delta(l) < length }
    end

    def licenses_sorted
      potential_licenses.sort_by { |l| length_delta(l) }
    end

    def matches
      @matches ||= begin
        licenses_sorted.each { |l| l.match = 1 - percent_changed(l) }
        licenses_sorted.sort_by { |l| l.match }.select { |l| l.match > 0}.reverse
      end
    end

    def match
      matches.first if matches
    end

    def percent_changed(license)
      (Levenshtein.distance(content, license.body).to_f / content.length.to_f).abs
    end

    def diff(options=nil)
      Diffy::Diff.new(match.body, content).to_s(options)
    end

  end
end
