module Licensee
  module Matchers
    # Matches README files that include a license by reference
    class Reference < Licensee::Matchers::Matcher
      def match
        License.all(hidden: true, psuedo: false).find do |license|
          /\b#{license.title_regex}\b/ =~ file.content
        end
      end

      def confidence
        raise 'Not implemented'
      end
    end
  end
end
