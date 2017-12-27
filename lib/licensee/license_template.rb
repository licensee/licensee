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

    FIELD_REGEX = /(?<field><<var;name=(?<name>.+?);original=(?<original>.+?);match=(?<match>.+?)>>)/

    def initialize(spdx_id)
      @spdx_id = spdx_id
    end

    def regex
      @regex ||= Regexp.new(content_with_fields_replaced, Regexp::IGNORECASE)
    end

    private

    def content_with_fields_replaced
      return @content_with_fields_replaced if defined? @content_with_fields_replaced
      replacements = fields.map do |field|
        [Regexp.escape(field[:field]), "(?<#{field[:name]}>#{field[:match]}?)"]
      end
      @content_with_fields_replaced = content_escaped.gsub(/<<var.+?>>/, replacements.to_h)
    end

    def fields
      @fields ||= content_normalized.to_enum(:scan, FIELD_REGEX).map { Regexp.last_match }
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
