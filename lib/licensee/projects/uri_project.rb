# URI-based project
#
# Analyzes a given URI for license information
require 'net/http'
require 'uri'

module Licensee
  class UriProject < Project
    def initialize(path, **args)
      @uri = path
      super(**args)
    end

    def load_file(file)
      Net::HTTP.get(file[:uri])
    end

    def files
      [{name: @uri.to_s, uri: @uri}]
    end
  end
end