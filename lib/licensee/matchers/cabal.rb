module Licensee
  module Matchers
    class Cabal < Licensee::Matchers::Package
      # While we could parse the cabal file, prefer
      # a lenient regex for speed and security. Moar parsing moar problems.
      LICENSE_REGEX = /^\s*license\s*\:\s*([a-z\-0-9\.]+)\s*$/ix

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        match[1].downcase if match && match[1]
      end
    end
  end
end
