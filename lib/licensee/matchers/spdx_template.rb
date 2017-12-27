module Licensee
  module Matchers
    class SpdxTemplate < Licensee::Matchers::Matcher
      def match
        licenses.find do |license|
          puts license.key unless license.template
          license.template.regex =~ file.content_normalized
        end
      end

      def confidence
        100
      end
    end
  end
end
