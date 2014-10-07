class Licensee
  class Matcher
    attr_reader :file

    def self.match(file)
      self.new(file).match
    end

    def initialize(file)
      @file = file
    end

    def matches
      []
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
