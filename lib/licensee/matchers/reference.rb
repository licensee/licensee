module Licensee
  module Matchers
    # Matches README files that include a license by reference
    class Reference < Licensee::Matchers::Matcher
      def match
        License.all(hidden: true, psuedo: false).find do |license|
          title_or_source = [license.title_regex, license.source_regex].compact
          /\b#{Regexp.union(title_or_source)}\b/ =~ file.content
        end
      end

      def confidence
        90
      end
    end
  end
end
