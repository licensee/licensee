module Licensee
  class Project
    class Readme < LicenseFile
      SCORES = {
        /\AREADME\z/i => 1.0,
        /\AREADME\.(md|markdown|txt)\z/i => 0.9
      }

      CONTENT_REGEX = /^#+ Licen[sc]e$(.*?)(?=#+|\z)/im

      def self.name_score(filename)
        SCORES.each do |pattern, score|
          return score if pattern =~ filename
        end
        return 0.0
      end

      def self.license_content(content)
        match = CONTENT_REGEX.match(content)
        match[1].strip if match
      end
    end
  end
end
