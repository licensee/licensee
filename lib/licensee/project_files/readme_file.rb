module Licensee
  module ProjectFiles
    class ReadmeFile < Licensee::ProjectFiles::LicenseFile
      SCORES = {
        /\AREADME\z/i                          => 1.0,
        /\AREADME\.(md|markdown|mdown|txt)\z/i => 0.9
      }.freeze

      CONTENT_REGEX = /^
          (?:\#+\sLicen[sc]e     # Start of hashes-based license header
             |
             Licen[sc]e\n[-=]+)$ # Start of underlined license header
          (.*?)                  # License content
          (?=^(?:\#+             # Next hashes-based header
                 |
                 [^\n]+\n[-=]+)  # Next of underlined header
             |
             \z)                 # End of file
        /mix

      def possible_matchers
        super.push(Matchers::Reference)
      end

      def self.name_score(filename)
        SCORES.each do |pattern, score|
          return score if pattern =~ filename
        end
        0.0
      end

      def self.license_content(content)
        match = CONTENT_REGEX.match(content)
        match[1].strip if match
      end
    end
  end
end
