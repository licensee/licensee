# frozen_string_literal: true

module Licensee
  class ConfigFile < ContentFile
    include Licensee::HashHelper
    HASH_METHODS = %i[ignored_paths].freeze

    FILENAME = '.licensee.yml'
    KEYS = %i[ignore].freeze

    def ignored?(file)
      ignored_paths.any? { |pattern| File.fnmatch(pattern, file[:name]) }
    end

    # Returns an arary of path strings to ignore
    # Always includes the config file path so that licensee doesn't match on the ignore file
    def ignored_paths
      @ignored_paths ||= if config && config['ignore'].is_a?(Array)
                           config['ignore'].push(FILENAME)
                         else
                           [FILENAME]
                         end
    end

    def self.name_score(name)
      name == FILENAME ? 1 : 0
    end

    def config
      @config ||= YAML.safe_load(content)
    rescue Psych::Exception => _e
      nil
    end
  end
end
