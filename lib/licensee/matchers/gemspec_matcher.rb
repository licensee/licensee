module Licensee
  module Matchers
    class Gemspec < Package
      # We definitely don't want to be evaling arbitrary Gemspec files
      # While not 100% accurate, use some lenient regex to try to grep the
      # license declaration from the Gemspec as a string, if any
      LICENSE_REGEX = /
        ^\s*[a-z0-9_]+\.license\s*\=\s*[\'\"]([a-z\-0-9\.]+)[\'\"]\s*$
        /ix

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        match[1].downcase if match && match[1]
      end
    end
  end
end
