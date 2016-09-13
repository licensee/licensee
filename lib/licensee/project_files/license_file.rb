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
        return 0.8 if filename =~ /\Acopy(ing|right)\z/i
        return 0.7 if filename =~ /\Acopy(ing|right)\.(md|markdown|txt)\z/i
        return 0.6 if filename =~ /\A(un)?licen[sc]e\.[^.]+\z/i
        return 0.5 if filename =~ /\Acopy(ing|right)\.[^.]+\z/i
        return 0.4 if filename =~ /(un)?licen[sc]e/i
        return 0.3 if filename =~ /copy(ing|right)/i
        0.0
      end

      # case-insensitive block to determine if the given file is LICENSE.lesser
      def self.lesser_gpl_score(filename)
        filename.casecmp('copying.lesser').zero? ? 1 : 0
      end
    end
  end
end
