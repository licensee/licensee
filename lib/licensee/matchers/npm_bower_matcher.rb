class Licensee
  class NpmBowerMatcher < PackageMatcher

    private

    def data
      @data ||= JSON.parse(file.content)
    rescue JSON::ParserError
      nil
    end

    def license_property
      data["license"].downcase if data
    end
  end
end
