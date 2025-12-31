# frozen_string_literal: true

require 'digest'
require_relative 'content_helper/constants'
require_relative 'content_helper/normalization_methods'
require_relative 'content_helper/similarity_methods'

module Licensee
  # Text normalization, hashing, wrapping, and similarity helpers for license content.
  module ContentHelper
    include Constants
    include NormalizationMethods
    include SimilarityMethods

    # A set of each word in the license, without duplicates
    def wordset
      @wordset ||= content_normalized&.scan(%r{(?:[\w/-](?:'s|(?<=s)')?)+})&.to_set
    end

    # Number of characters in the normalized content
    def length
      return 0 unless content_normalized

      content_normalized.length
    end

    # Given another license or project file, calculates the difference in length
    def length_delta(other)
      (length - other.length).abs
    end

    # SHA1 of the normalized content
    def content_hash
      @content_hash ||= DIGEST.hexdigest content_normalized
    end

    # Backwards compatibalize constants to avoid a breaking change
    def self.const_missing(const)
      key = const.to_s.downcase.gsub('_regex', '').to_sym
      REGEXES[key] || super
    end

    # Wrap text to the given line length
    def self.wrap(text, line_width = 80)
      return if text.nil?

      text = normalize_for_wrapping(text)
      wrapped = wrap_lines(text, line_width)
      wrapped.strip
    end

    def self.normalize_for_wrapping(text)
      text = text.clone
      text.gsub!(REGEXES[:bullet]) { |m| "\n#{m}\n" }
      text.gsub!(/([^\n])\n([^\n])/, '\\1 \\2')
      text
    end

    def self.wrap_lines(text, line_width)
      text.split("\n").map { |line| wrap_line(line, line_width) }.join("\n")
    end

    def self.wrap_line(line, line_width)
      return line if line =~ REGEXES[:hrs] || line.length <= line_width

      line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
    end

    def self.format_percent(float)
      "#{format('%<float>.2f', float: float)}%"
    end

    def self.title_regex
      @title_regex ||= begin
        licenses = Licensee::License.all(hidden: true, psuedo: false)
        titles = licenses.map(&:title_regex)

        # Title regex must include the version to support matching within
        # families, but for sake of normalization, we can be less strict
        without_versions = licenses.map do |license|
          next if license.title == license.name_without_version

          Regexp.new Regexp.escape(license.name_without_version), 'i'
        end
        titles.concat(without_versions.compact)

        /#{START_REGEX}\(?(?:the )?#{Regexp.union titles}.*?$/i
      end
    end

    private

    def _content
      @_content ||= content.to_s.dup.strip
    end
  end
end
