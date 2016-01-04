module Licensee
  class Project
    class LicenseFile < Licensee::Project::File
      include Licensee::ContentHelper

      def possible_matchers
        [Matchers::Copyright, Matchers::Exact, Matchers::Dice]
      end

      def attribution
        matches = /^#{Matchers::Copyright::REGEX}$/i.match(content)
        matches[0].strip if matches
      end

      def self.name_score(filename)
        return 1.0 if filename =~ /\A(un)?licen[sc]e\z/i
        return 0.9 if filename =~ /\A(un)?licen[sc]e\.(md|markdown|txt)\z/i
        return 0.8 if filename =~ /\Acopy(ing|right)(\.[^.]+)?\z/i
        return 0.7 if filename =~ /\A(un)?licen[sc]e\.[^.]+\z/i
        return 0.5 if filename =~ /licen[sc]e/i
        return 0.0
      end
    end
  end
end
