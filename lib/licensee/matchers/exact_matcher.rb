class Licensee
  class ExactMatcher < Matcher
    def match
      Licensee.licenses(:hidden => true).find { |l| l.body_normalized == file.content_normalized }
    end

    def confidence
      100
    end
  end
end
