class Licensee
  class GemspecMatcher < PackageMatcher

    LICENSE_REGEX = /^\s*[a-z0-9_]+\.license\s*\=\s*[\'\"]([a-z\-0-9\.]+)[\'\"]\s*$/i

    private

    # We definitely don't want to be evaling arbitrary Gemspec files
    # While not 100% accurate, use some lenient regex to try to grep the
    # license declaration from the Gemspec as a string, if any
    def license_property
      match = file.content.match LICENSE_REGEX
      match[1].downcase if match
    end
  end
end
