module Licensee
  module Matchers
    class Cran < Package
      attr_reader :file

      # While we could parse the DESCRIPTION file, prefer
      # a lenient regex for speed and security. Moar parsing moar problems.
      LICENSE_REGEX = /
        ^license:\s*(.+)
      /ix

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        return unless match && match[1]

        # Remove The common + file LICENSE text
        match = match[1].gsub(/\s* [+] \s* file \s+ LICENSE$/x,'')

        # Match GPL (>=2)
        m = match.match(/^GPL \s* [(] \s* >= \s* ([23]) \s* [)]/x)
        return "gpl-#{m[1]}.0" if m && m[1]

        # Match GPL-2
        m = match.match(/^GPL-([23])/)
        return "gpl-#{m[1]}.0" if m && m[1]

        match.downcase
      end
    end
  end
end
