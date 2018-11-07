module Licensee
  module Matchers
    class FieldAware < Licensee::Matchers::Matcher
      def match
        return @match if defined? @match

        @match = potential_matches.find do |potential_match|
          file.content_normalized =~ regex_for(potential_match)
        end
      end

      def confidence
        98
      end

      private

      FIELD_PLACEHOLDER = 'LICENSEE_FIELD_LICENSEE'.freeze
      FIELD_PLACEHOLDER_REGEX = /licensee\\ field\\ licensee/.freeze

      def regex_for(potential_match)
        pm = potential_match.dup
        pm.instance_variable_set '@content_normalized', nil
        pm.instance_variable_set '@content_without_title_and_version', nil
        field_regex = /#{Regexp.union(pm.fields.map(&:raw_text))}/i
        pm.content = pm.content.gsub(field_regex, FIELD_PLACEHOLDER)
        regex = Regexp.escape(pm.content_normalized)
        regex = regex.gsub(FIELD_PLACEHOLDER_REGEX, '([a-z ]+?)')
        Regexp.new(regex)
      end
    end
  end
end
