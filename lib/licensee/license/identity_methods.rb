# frozen_string_literal: true

module Licensee
  class License
    module IdentityMethods
      SOURCE_PREFIX = %r{https?://(?:www\.)?}i
      SOURCE_SUFFIX = %r{(?:\.html?|\.txt|/)(?:\?[^\s]*)?}i

      def spdx_id
        return meta.spdx_id if meta.spdx_id
        return 'NOASSERTION' if key == 'other'

        'NONE' if key == 'no-license'
      end

      # Returns the human-readable license name
      def name
        return key.tr('-', ' ').capitalize if pseudo_license?

        title || spdx_id
      end

      def name_without_version
        /(.+?)(( v?\d\.\d)|$)/.match(name)[1]
      end

      def title_regex
        return @title_regex if defined? @title_regex

        string = name.downcase.sub('*', 'u')
        simple_title_regex = Regexp.new string, 'i'
        string.sub!(/\Athe /i, '')
        string.sub!(/,? version /, ' ')
        string.sub!(/v(\d+\.\d+)/, '\\1')
        string = Regexp.escape(string)
        string = string.sub(/\\ licen[sc]e/i, '(?:\\ licen[sc]e)?')
        version_match = string.match(/\d+\\.(\d+)/)
        if version_match
          vsub = if version_match[1] == '0'
                   ',?\s+(?:version\ |v(?:\. )?)?\\1(\\2)?'
                 else
                   ',?\s+(?:version\ |v(?:\. )?)?\\1\\2'
                 end
          string = string.sub(/\\ (\d+)(\\.\d+)/, vsub)
        end
        string = string.sub(/\bgnu\\ /, '(?:GNU )?')
        title_regex = Regexp.new string, 'i'

        string = key.sub('-', '[- ]')
        string.sub!('.', '\\.')
        string << '(?:\\ licen[sc]e)?'
        key_regex = Regexp.new string, 'i'

        parts = [simple_title_regex, title_regex, key_regex]
        parts.push Regexp.new meta.nickname.sub(/\bGNU /i, '(?:GNU )?') if meta.nickname

        @title_regex = Regexp.union parts
      end

      # Returns a regex that will match the license source
      def source_regex
        return @source_regex if defined? @source_regex
        return unless meta.source

        source = meta.source.dup.sub(/\A#{SOURCE_PREFIX}/o, '')
        source = source.sub(/#{SOURCE_SUFFIX}\z/o, '')

        escaped_source = Regexp.escape(source)
        @source_regex = /#{SOURCE_PREFIX}#{escaped_source}(?:#{SOURCE_SUFFIX})?/i
      end

      def url
        URI.join(Licensee::DOMAIN, "/licenses/#{key}/").to_s
      end

      def ==(other)
        other.is_a?(self.class) && key == other.key
      end

      def other?
        key == 'other'
      end

      def gpl?
        ['gpl-2.0', 'gpl-3.0'].include?(key)
      end

      def lgpl?
        ['lgpl-2.1', 'lgpl-3.0'].include?(key)
      end

      # Is this license a Creative Commons license?
      def creative_commons?
        key.start_with?('cc-')
      end
      alias cc? creative_commons?

      def pseudo_license?
        PSEUDO_LICENSES.include?(key)
      end
    end
  end
end
