# frozen_string_literal: true

module Licensee
  class IgnoreFile < ContentFile
    include Licensee::HashHelper
    HASH_METHODS = %i[ignored_paths].freeze

    FILENAME = '.licensee-ignore'

    # Default IgnoreFile to maintain bacckward compatability
    DEFAULTS = %w[xml go].map { |ext| "*.#{ext}" }.freeze

    def self.default
      @default ||= new(DEFAULTS.join("\n"))
    end

    def ignored?(file)
      ignored_paths.any? { |pattern| File.fnmatch(pattern, file[:name]) }
    end

    # Returns an arary of path strings to ignore
    # Always includes the ignore file path so that licensee doesn't match on the ignore file
    def ignored_paths
      @ignored_paths ||= content.split("\n").map(&:strip).push(FILENAME)
    end

    def self.name_score(name)
      name == FILENAME ? 1 : 0
    end
  end
end
