module Licensee
  module Matchers
    class DistZilla < Package
      attr_reader :file

      LICENSE_REGEX = /
        ^license\s*=\s*([a-z\-0-9\.]+)
      /ix

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        match[1].downcase if match && match[1]
      end
    end
  end
end
