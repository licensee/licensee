# frozen_string_literal: true

module Licensee
  LicenseField = Struct.new(:name, :description)

  # Represents a templated field placeholder used in license text.
  class LicenseField
    class << self
      # Return a single license field
      #
      # key - string representing the field's text
      #
      # Returns a LicenseField
      def find(key)
        @all.find { |f| f.key == key }
      end

      # Returns an array of strings representing all field keys
      def keys
        @keys ||= all.map(&:key)
      end

      # Returns an array of all known LicenseFields
      def all
        @all ||= begin
          path   = '../../vendor/choosealicense.com/_data/fields.yml'
          path   = File.expand_path path, __dir__
          fields = YAML.safe_load_file(path)
          fields.map { |field| from_hash(field) }
        end
      end

      # Builds a LicenseField from a hash of properties
      def from_hash(hash)
        ordered_array = hash.values_at(*members.map(&:to_s))
        new(*ordered_array)
      end

      # Given an array of keys, returns an array of coresponding LicenseFields
      def from_array(array)
        array.map { |key| find(key) }
      end

      # Given a license body, returns an array of included LicneseFields
      def from_content(content)
        return [] unless content

        from_array content.scan(FIELD_REGEX).flatten
      end
    end

    alias key name
    FIELD_REGEX = /\[(#{Regexp.union(keys)})\]/

    # The human-readable field name
    def label
      key.sub('fullname', 'full name').capitalize
    end
    alias to_s label

    def raw_text
      "[#{key}]"
    end
  end
end
