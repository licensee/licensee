module Licensee
  class LicenseTemplate
    class << self
      def template_dir
        File.expand_path '../../vendor/spdx-license-list/template', __dir__
      end

      def find(key)
        keys_templates[key]
      end

      def all
        @all ||= keys_templates.map { |_k, t| t }
      end

      private

      def keys_templates
        @keys_templates ||= begin
          licenses = Licensee::License.all(hidden: true, pseudo: false)
          licenses.map { |l| [l.key, new(l.spdx_id)] }.to_h
        end
      end
    end

    include ContentHelper
    attr_reader :spdx_id

    VAR_REGEX = /var;name=\"(?<name>.+?)\"/.freeze
    ORIGINAL_REGEX = /original=\"(?<original>.+?)\"/.freeze
    MATCH_REGEX = /match=\"(?<match>.+?)\"/.freeze
    FIELD_REGEX = /(?<field><<#{VAR_REGEX};#{ORIGINAL_REGEX};#{MATCH_REGEX}>>)/.freeze
    OPTIONAL_REGEX = /<<beginoptional>>(?:\\ )?(.*?)<<endoptional>>(?:\\ )?\s*/.freeze

    def initialize(spdx_id)
      @spdx_id = spdx_id
    end

    def regex
      @regex ||= Regexp.new(content_with_field_regex, Regexp::IGNORECASE)
    end

    def eql?(other)
      spdx_id == other.spdx_id
    end
    alias == eql?

    private

    def content_with_field_regex
      return @content_with_field_regex if defined? @content_with_field_regex

      replacements = fields.map do |field|
        [Regexp.escape(field[:field]), "(?<#{field[:name]}>#{field[:match]}?)"]
      end

      @content_with_field_regex = content_escaped.dup
      @content_with_field_regex.gsub!(/>>\\ ([.,])/, '>>\1')
      @content_with_field_regex.gsub!(/\/>/, '/?>')
      @content_with_field_regex.gsub!(/<<var.+?>>/, replacements.to_h)
      @content_with_field_regex.gsub!(/<<beginOptional>>\\?\s*/i, '(?:')
      @content_with_field_regex.gsub!(/\\?\s*<<endOptional>>\\?\s*/i, ')?\s*')

      @content_with_field_regex.gsub!('\\ \\ ', '\\ ')

      @content_with_field_regex
    end

    def fields
      @fields ||= begin
        content_normalized.to_enum(:scan, FIELD_REGEX).map { Regexp.last_match }
      end
    end

    def content_escaped
      @content_escaped ||= Regexp.escape(content_normalized)
    end

    def content
      @contents ||= File.read(path)
    end

    def path
      File.expand_path "#{spdx_id}.template.txt", LicenseTemplate.template_dir
    end
  end
end
