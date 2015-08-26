class Licensee
  class NpmBowerMatcher < Matcher

    def match
      Licensee.licenses.find { |l| l.key == license_property } if file.package?
    end

    def confidence
      80
    end

    private

    def data
      @data ||= JSON.parse(file.content)
    rescue JSON::ParserError
      nil
    end

    def license_property
      data["license"] if data
    end
  end
end
