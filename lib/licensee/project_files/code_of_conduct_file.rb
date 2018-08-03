module Licensee
  module ProjectFiles
    class CodeOfConductFile < Licensee::ProjectFiles::ProjectFile
      include Licensee::ContentHelper

      PREFERRED_EXT = %w[md markdown txt].freeze
      BASENAME_REGEX = /(citizen[_-])?code[_-]of[_-]conduct/i
      FILENAME_REGEX = /^#{BASENAME_REGEX}\.#{Regexp.union(PREFERRED_EXT)}/i

      def self.name_score(filename)
        if filename =~ FILENAME_REGEX
          1.0
        else
          0.0
        end
      end

      def possible_matchers
        [Matchers::Exact, Matchers::Dice] #Matchers::CodeOfConduct]
      end
    end
  end
end
