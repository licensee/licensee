module Licensee
  class Project
    class LicenseFile < Licensee::Project::File
      include Licensee::ContentHelper

      # List of extensions to give preference to
      PREFERRED_EXT = %w(md markdown txt).freeze
      PREFERRED_EXT_REGEX = /\.#{Regexp.union(PREFERRED_EXT)}\z/

      # Regex to match any extension
      ANY_EXT_REGEX = %r{\.[^./]+\z}

      # Regex to match, LICENSE, LICENCE, unlicense, etc.
      LICENSE_REGEX = /(un)?licen[sc]e/i

      # Regex to match COPYING, COPYRIGHT, etc.
      COPYING_REGEX = /copy(ing|right)/i

      # Hash of Regex => score with which to score potential license files
      FILENAME_REGEXES = {
        /\A#{LICENSE_REGEX}\z/                       => 1.0, # LICENSE
        /\A#{LICENSE_REGEX}#{PREFERRED_EXT_REGEX}\z/ => 0.9, # LICENSE.md
        /\A#{COPYING_REGEX}\z/                       => 0.8, # COPYING
        /\A#{COPYING_REGEX}#{PREFERRED_EXT_REGEX}\z/ => 0.7, # COPYING.md
        /\A#{LICENSE_REGEX}#{ANY_EXT_REGEX}\z/       => 0.6, # LICENSE.textile
        /\A#{COPYING_REGEX}#{ANY_EXT_REGEX}\z/       => 0.5, # COPYING.textile
        /#{LICENSE_REGEX}/                           => 0.4, # LICENSE-MIT
        /#{COPYING_REGEX}/                           => 0.3, # COPYING-MIT
        //                                           => 0.0  # Catch all
      }.freeze

      def possible_matchers
        [
          Matchers::Copyright, Matchers::Exact,
          Matchers::FalsePositive, Matchers::Dice
        ]
      end

      def attribution
        matches = /^#{Matchers::Copyright::REGEX}$/i.match(content)
        matches[0].strip if matches
      end

      def self.name_score(filename)
        FILENAME_REGEXES.find { |regex, _| filename =~ regex }[1]
      end

      # case-insensitive block to determine if the given file is LICENSE.lesser
      def self.lesser_gpl_score(filename)
        filename.casecmp('copying.lesser').zero? ? 1 : 0
      end
    end
  end
end
