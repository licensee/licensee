# frozen_string_literal: true

require 'uri'

module Licensee
  class InvalidLicense < ArgumentError; end
  class License
    @all = {}
    @keys_licenses = {}

    class << self
      # All license objects defined via Licensee (via choosealicense.com)
      #
      # Options:
      # - :hidden - boolean, return hidden licenses (default: false)
      # - :featured - boolean, return only (non)featured licenses (default: all)
      #
      # Returns an Array of License objects.
      def all(options = {})
        @all[options] ||= begin
          # TODO: Remove in next major version to avoid breaking change
          options[:pseudo] ||= options[:psuedo] unless options[:psuedo].nil?

          options = DEFAULT_OPTIONS.merge(options)
          output = licenses.dup
          output.reject!(&:hidden?) unless options[:hidden]
          output.reject!(&:pseudo_license?) unless options[:pseudo]
          output.sort_by!(&:key)
          return output if options[:featured].nil?

          output.select { |l| l.featured? == options[:featured] }
        end
      end

      def keys
        @keys ||= license_files.map do |license_file|
          ::File.basename(license_file, '.txt').downcase
        end + PSEUDO_LICENSES
      end

      def find(key, options = {})
        options = { hidden: true }.merge(options)
        keys_licenses(options)[key.downcase]
      end
      alias [] find
      alias find_by_key find

      # Given a license title or nickname, fuzzy match the license
      def find_by_title(title)
        License.all(hidden: true, pseudo: false).find do |license|
          title =~ /\A(the )?#{license.title_regex}( license)?\z/i
        end
      end

      def license_dir
        dir = ::File.dirname(__FILE__)
        ::File.expand_path '../../vendor/choosealicense.com/_licenses', dir
      end

      def license_files
        @license_files ||= Dir.glob("#{license_dir}/*.txt")
      end

      private

      def licenses
        @licenses ||= keys.map { |key| new(key) }
      end

      def keys_licenses(options = {})
        @keys_licenses[options] ||= all(options).map { |l| [l.key, l] }.to_h
      end
    end

    attr_reader :key

    # Preserved for backwards compatibility
    YAML_DEFAULTS = Licensee::LicenseMeta.members

    # Pseudo-license are license placeholders with no content
    #
    # `other` - The project had a license, but we were not able to detect it
    # `no-license` - The project is not licensed (e.g., all rights reserved)
    #
    # Note: A lack of detected license will be a nil license
    PSEUDO_LICENSES = %w[other no-license].freeze

    # Default options to use when retrieving licenses via #all
    DEFAULT_OPTIONS = {
      hidden:   false,
      featured: nil,
      pseudo:   true
    }.freeze

    ALT_TITLE_REGEX = {
      'bsd-2-clause'       => /bsd 2-clause(?: \"simplified\")?/i,
      'bsd-3-clause'       => /bsd 3-clause(?: \"new\" or \"revised\")?/i,
      'bsd-3-clause-clear' => /(?:clear bsd|bsd 3-clause(?: clear)?)/i
    }.freeze

    SOURCE_PREFIX = %r{https?://(?:www\.)?}i.freeze
    SOURCE_SUFFIX = %r{(?:\.html?|\.txt|\/)(?:\?[^\s]*)?}i.freeze

    HASH_METHODS = %i[
      key spdx_id meta url rules fields other? gpl? lgpl? cc?
    ].freeze

    include Licensee::ContentHelper
    include Licensee::HashHelper
    extend Forwardable
    def_delegators :meta, *LicenseMeta.helper_methods

    def initialize(key)
      @key = key.downcase
    end

    # Path to vendored license file on disk
    def path
      @path ||= File.expand_path "#{@key}.txt", Licensee::License.license_dir
    end

    # License metadata from YAML front matter with defaults merged in
    def meta
      @meta ||= LicenseMeta.from_yaml(yaml)
    end

    def spdx_id
      return meta.spdx_id if meta.spdx_id
      return 'NOASSERTION' if key == 'other'
      return 'NONE' if key == 'no-license'
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

      title_regex = ALT_TITLE_REGEX[key]
      title_regex ||= begin
        string = name.downcase.sub('*', 'u')
        string.sub!(/\Athe /i, '')
        string.sub!(/,? version /, ' ')
        string.sub!(/v(\d+\.\d+)/, '\1')
        string = Regexp.escape(string)
        string = string.sub(/\\ licen[sc]e/i, '(?:\ licen[sc]e)?')
        string = string.sub(/\\ (\d+\\.\d+)/, ',?\s+(?:version\ |v(?:\. )?)?\1')
        string = string.sub(/\bgnu\\ /, '(?:GNU )?')
        Regexp.new string, 'i'
      end

      parts = [title_regex, key]
      if meta.nickname
        parts.push Regexp.new meta.nickname.sub(/\bGNU /i, '(?:GNU )?')
      end

      @title_regex = Regexp.union parts
    end

    # Returns a regex that will match the license source
    #
    # The following variations are supported (as presumed identical):
    # 1. HTTP or HTTPS
    # 2. www or non-www
    # 3. .txt, .html, .htm, or / suffix
    #
    # Returns the regex, or nil if no source exists
    def source_regex
      return @source_regex if defined? @source_regex
      return unless meta.source

      source = meta.source.dup.sub(/\A#{SOURCE_PREFIX}/, '')
      source = source.sub(/#{SOURCE_SUFFIX}\z/, '')

      escaped_source = Regexp.escape(source)
      @source_regex = /#{SOURCE_PREFIX}#{escaped_source}(?:#{SOURCE_SUFFIX})?/i
    end

    def other?
      key == 'other'
    end

    def gpl?
      key == 'gpl-2.0' || key == 'gpl-3.0'
    end

    def lgpl?
      key == 'lgpl-2.1' || key == 'lgpl-3.0'
    end

    # Is this license a Creative Commons license?
    def creative_commons?
      key.start_with?('cc-')
    end
    alias cc? creative_commons?

    # The license body (e.g., contents - frontmatter)
    def content
      @content ||= parts[2] if parts && parts[2]
    end
    alias to_s content
    alias text content
    alias body content

    def url
      URI.join(Licensee::DOMAIN, "/licenses/#{key}/").to_s
    end

    def ==(other)
      !other.nil? && key == other.key
    end

    def pseudo_license?
      PSEUDO_LICENSES.include?(key)
    end

    def rules
      @rules ||= LicenseRules.from_meta(meta)
    end

    def inspect
      "#<Licensee::License key=#{key}>"
    end

    # Returns an array of strings of substitutable fields in the license body
    def fields
      @fields ||= LicenseField.from_content(content)
    end

    # Returns a string with `[fields]` replaced by `{{{fields}}}`
    # Does not mangle non-supported fields in the form of `[field]`
    def content_for_mustache
      @content_for_mustache ||= begin
        content.gsub(LicenseField::FIELD_REGEX, '{{{\1}}}')
      end
    end

    private

    # Raw content of license file, including YAML front matter
    def raw_content
      return if pseudo_license?
      unless File.exist?(path)
        raise Licensee::InvalidLicense, "'#{key}' is not a valid license key"
      end

      @raw_content ||= File.read(path, encoding: 'utf-8')
    end

    def parts
      return unless raw_content

      @parts ||= raw_content.match(/\A(---\n.*\n---\n+)?(.*)/m).to_a
    end

    def yaml
      @yaml ||= parts[1] if parts
    end
  end
end
