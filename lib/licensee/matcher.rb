# Abstract class to describe different matching strategies
# Must respond to:
#   - match
#   - confidence
#
# Can assume file will be a Licensee::LicenseFile instance
class Licensee
  class Matcher
    attr_reader :file

    def self.match(file)
      self.new(file).match
    end

    def initialize(file)
      @file = file
    end

    def match
      nil
    end

    def confidence
      0
    end
    alias_method :similarity, :confidence
  end
end
