class Licensee
  class ExactMatcher < Matcher
    def matches
      [match]
    end

    def match
      Licensee::Licenses.list.find { |l| l.body_normalized == file.content_normalized }
    end

    def confidence
      100
    end
  end
end
