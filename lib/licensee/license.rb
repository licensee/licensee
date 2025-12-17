# frozen_string_literal: true

require 'uri'

require_relative 'license/class_methods'
require_relative 'license/content_methods'
require_relative 'license/identity_methods'

module Licensee
  class InvalidLicense < ArgumentError; end

  module LicenseAllHelper
    module_function

    def normalize_all_options(options, defaults)
      normalized = options.dup
      # TODO: Remove in next major version to avoid breaking change
      normalized[:pseudo] = normalized[:psuedo] if normalized[:pseudo].nil? && !normalized[:psuedo].nil?
      defaults.merge(normalized)
    end

    def apply_all_filters!(licenses, options)
      licenses.reject!(&:hidden?) unless options[:hidden]
      licenses.reject!(&:pseudo_license?) unless options[:pseudo]
    end

    def filter_featured(licenses, featured)
      return licenses if featured.nil?

      licenses.select { |l| l.featured? == featured }
    end
  end

  class License
    @all = {}
    @keys_licenses = {}

    extend ClassMethods

    attr_reader :key

    # Preserved for backwards compatibility
    YAML_DEFAULTS = Licensee::LicenseMeta.members

    # Pseudo-license are license placeholders with no content
    #
    # `other` - The project had a license, but we were not able to detect it
    # `no-license` - The project is not licensed (e.g., all rights reserved)
    #
    # NOTE: A lack of detected license will be a nil license
    PSEUDO_LICENSES = %w[other no-license].freeze

    # Default options to use when retrieving licenses via #all
    DEFAULT_OPTIONS = {
      hidden:   false,
      featured: nil,
      pseudo:   true
    }.freeze

    SOURCE_PREFIX = %r{https?://(?:www\.)?}i
    SOURCE_SUFFIX = %r{(?:\.html?|\.txt|/)(?:\?[^\s]*)?}i

    HASH_METHODS = %i[
      key spdx_id meta url rules fields other? gpl? lgpl? cc?
    ].freeze

    include Licensee::ContentHelper
    include Licensee::HashHelper
    include ContentMethods
    include IdentityMethods
    extend Forwardable

    def_delegators :meta, *(LicenseMeta.helper_methods - [:spdx_id])

    def initialize(key)
      @key = key.downcase
    end

    # License metadata from YAML front matter with defaults merged in
    def meta
      @meta ||= LicenseMeta.from_yaml(yaml)
    end

    def rules
      @rules ||= LicenseRules.from_meta(meta)
    end

    def inspect
      "#<Licensee::License key=#{key}>"
    end

    private

    def spdx_alt_segments
      @spdx_alt_segments ||= begin
        path = File.expand_path "#{spdx_id}.xml", Licensee::License.spdx_dir
        raw_xml = File.read(path, encoding: 'utf-8')
        text = raw_xml.match(%r{<text>(.*)</text>}m)[1]
        text.gsub!(%r{<copyrightText>.*?</copyrightText>}m, '')
        text.gsub!(%r{<titleText>.*?</titleText>}m, '')
        text.gsub!(%r{<optional.*?>.*?</optional>}m, '')
        text.scan(/<alt .*?>/m).size
      end
    end
  end
end
