class Licensee
  class PackageMatcher < Matcher

    def match
      Licensee.licenses.find { |l| l.key == license_property } if file.package?
    end

    def confidence
      80
    end

    def self.package_manager?
      true
    end
  end
end
