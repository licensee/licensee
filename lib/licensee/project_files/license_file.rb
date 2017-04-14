module Licensee
  class Project
    class LicenseFile < Licensee::Project::File
      include Licensee::ContentHelper

      # List of extensions to give preference to
      PREFERRED_EXT = %w[md markdown txt].freeze
      PREFERRED_EXT_REGEX = /\.#{Regexp.union(PREFERRED_EXT)}\z/

      # Regex to match any extension
      ANY_EXT_REGEX = %r{\.[^./]+\z}

      # Regex to match, LICENSE, LICENCE, unlicense, etc.
      LICENSE_REGEX = /(un)?licen[sc]e/i

      # Regex to match COPYING, COPYRIGHT, etc.
      COPYING_REGEX = /copy(ing|right)/i

      # Regex to match OFL.
      OFL_REGEX = /ofl/i

      # Hash of Regex => score with which to score potential license files
      FILENAME_REGEXES = {
        /\A#{LICENSE_REGEX}\z/                       => 1.0,  # LICENSE
        /\A#{LICENSE_REGEX}#{PREFERRED_EXT_REGEX}\z/ => 0.9,  # LICENSE.md
        /\A#{COPYING_REGEX}\z/                       => 0.8,  # COPYING
        /\A#{COPYING_REGEX}#{PREFERRED_EXT_REGEX}\z/ => 0.7,  # COPYING.md
        /\A#{LICENSE_REGEX}#{ANY_EXT_REGEX}\z/       => 0.6,  # LICENSE.textile
        /\A#{COPYING_REGEX}#{ANY_EXT_REGEX}\z/       => 0.5,  # COPYING.textile
        /#{LICENSE_REGEX}/                           => 0.4,  # LICENSE-MIT
        /#{COPYING_REGEX}/                           => 0.3,  # COPYING-MIT
        /\A#{OFL_REGEX}#{PREFERRED_EXT_REGEX}/       => 0.2,  # OFL.md
        /\A#{OFL_REGEX}#{ANY_EXT_REGEX}/             => 0.1,  # OFL.textile
        /\A#{OFL_REGEX}\z/                           => 0.05, # OFL
        //                                           => 0.0   # Catch all
      }.freeze

      # CC-NC and CC-ND are not open source licenses and should not be
      # detected as CC-BY or CC-BY-SA which are 98%+ similar
      CC_FALSE_POSITIVE_REGEX = /
        ^(creative\ commons\ )?Attribution-(NonCommercial|NoDerivatives)
      /xi

      def possible_matchers
        [Matchers::Copyright, Matchers::Exact, Matchers::Dice]
      end

      def attribution
        @attribution ||= begin
          matches = Matchers::Copyright::REGEX
                    .match(content_without_title_and_version)
          matches[0] if matches
        end
      end

      # Is this file likely to result in a creative commons false positive?
      def potential_false_positive?
        content.strip =~ CC_FALSE_POSITIVE_REGEX
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
