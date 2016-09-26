module Licensee
  module Matchers
    class Cran < Package
      # While we could parse the package.json or bower.json file, prefer
      # a lenient regex for speed and security. Moar parsing moar problems.
      LICENSE_REGEX = /
        ^license:\s*([a-z\-0-9\.]+)
      /ix

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        match[1].downcase if match && match[1]
      end
    end
  end
end
