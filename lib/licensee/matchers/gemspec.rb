module Licensee
  module Matchers
    class Gemspec < Licensee::Matchers::Package
      DECLARATION_REGEX = /
        ^\s*[a-z0-9_]+\.([a-z0-9_]+)\s*\=\s*[\'\"]([a-z\-0-9\.]+)[\'\"]\s*$
        /ix

      LICENSE_REGEX = /
           ^\s*[a-z0-9_]+\.license\s*\=\s*[\'\"]([a-z\-0-9\.]+)[\'\"]\s*$
           /ix

      private

      def license_property
        match = @file.content.match LICENSE_REGEX
        match[1].downcase if match && match[1]
      end

      def declarations
        @declarations ||= @file.content.match DECLARATION_REGEX
      end
    end
  end
end
