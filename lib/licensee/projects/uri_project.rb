# URI-based project
#
# Analyzes a given URI for license information
require 'net/http'
require 'uri'

module Licensee
  class UriProject < Project
    def initialize(path, **args)
      @uri = URI(path)
      raise UnsupportedProject if @uri.scheme !~ /^https?$/
      super(**args)
    end

    def load_file(file)
      Net::HTTP.get(file[:uri]) if @allow_remote
    end

    def files
      result = []
      result.push(name: @uri.to_s, uri: @uri) if @allow_remote
      result
    end
  end
end
