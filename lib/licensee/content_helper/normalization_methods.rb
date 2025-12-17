# frozen_string_literal: true

module Licensee
  module ContentHelper
    module NormalizationMethods
      # Content with the title and version removed
      # The first time should normally be the attribution line
      # Used to dry up `content_normalized` but we need the case sensitive
      # content with attribution first to detect attribuion in LicenseFile
      def content_without_title_and_version
        @content_without_title_and_version ||= begin
          @_content = nil
          ops = %i[html hrs comments markdown_headings link_markup title version]
          ops.each { |op| strip(op) }
          _content
        end
      end

      def content_normalized(wrap: nil)
        @content_normalized ||= normalize_content
        wrap ? Licensee::ContentHelper.wrap(@content_normalized, wrap) : @content_normalized
      end

      def normalize_content
        @_content = content_without_title_and_version.downcase
        (ContentHelper::NORMALIZATIONS.keys + %i[spelling span_markup bullets]).each { |op| normalize(op) }
        ContentHelper::STRIP_METHODS.each { |op| strip(op) }
        _content
      end

      private

      def strip(regex_or_sym)
        return unless _content

        if regex_or_sym.is_a?(Symbol)
          meth = "strip_#{regex_or_sym}"
          return send(meth) if respond_to?(meth, true)

          unless ContentHelper::REGEXES[regex_or_sym]
            raise ArgumentError, "#{regex_or_sym} is an invalid regex reference"
          end

          regex_or_sym = ContentHelper::REGEXES[regex_or_sym]
        end

        @_content = _content.gsub(regex_or_sym, ' ').squeeze(' ').strip
      end

      def strip_title
        strip(ContentHelper.title_regex) while _content =~ ContentHelper.title_regex
      end

      def strip_borders
        normalize(ContentHelper::REGEXES[:border_markup], '\\1')
      end

      def strip_comments
        lines = _content.split("\n")
        return if lines.one?
        return unless lines.all? { |line| line =~ ContentHelper::REGEXES[:comment_markup] }

        strip(:comment_markup)
      end

      def strip_copyright
        regex = Regexp.union(Matchers::Copyright::REGEX, ContentHelper::REGEXES[:all_rights_reserved])
        strip(regex) while _content =~ regex
      end

      def strip_cc0_optional
        return unless _content.include? 'associating cc0'

        strip(ContentHelper::REGEXES[:cc_legal_code])
        strip(ContentHelper::REGEXES[:cc0_info])
        strip(ContentHelper::REGEXES[:cc0_disclaimer])
      end

      def strip_cc_optional
        return unless _content.include? 'creative commons'

        strip(ContentHelper::REGEXES[:cc_dedication])
        strip(ContentHelper::REGEXES[:cc_wiki])
      end

      def strip_unlicense_optional
        return unless _content.include? 'unlicense'

        strip(ContentHelper::REGEXES[:unlicense_info])
      end

      def strip_end_of_terms
        body, _partition, _instructions = _content.partition(ContentHelper::END_OF_TERMS_REGEX)
        @_content = body
      end

      def normalize_span_markup
        normalize(ContentHelper::REGEXES[:span_markup], '\\1')
      end

      def strip_link_markup
        normalize(ContentHelper::REGEXES[:link_markup], '\\1')
      end

      def strip_html
        return unless respond_to?(:filename) && filename
        return unless /\.html?/i.match?(File.extname(filename))

        require 'reverse_markdown'
        @_content = ReverseMarkdown.convert(_content, unknown_tags: :bypass)
      end

      def normalize(from_or_key, to = nil)
        operation = { from: from_or_key, to: to } if to
        operation ||= ContentHelper::NORMALIZATIONS[from_or_key]

        if operation
          @_content = _content.gsub operation[:from], operation[:to]
        elsif respond_to?(:"normalize_#{from_or_key}", true)
          send(:"normalize_#{from_or_key}")
        else
          raise ArgumentError, "#{from_or_key} is an invalid normalization"
        end
      end

      def normalize_spelling
        normalize(/\b#{Regexp.union(ContentHelper::VARIETAL_WORDS.keys)}\b/, ContentHelper::VARIETAL_WORDS)
      end

      def normalize_bullets
        normalize(ContentHelper::REGEXES[:bullet], "\n\n- ")
        normalize(/\)\s+\(/, ')(')
      end
    end
  end
end
