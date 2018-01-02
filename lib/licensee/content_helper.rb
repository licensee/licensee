require 'set'
require 'digest'

module Licensee
  module ContentHelper
    DIGEST = Digest::SHA1
    START_REGEX = /(?<=\A|<<endOptional>>)\s*/i
    END_OF_TERMS_REGEX = /^[\s#*_]*end of terms and conditions\s*$/i
    HR_REGEX = /^\s*[=\-\*][=\-\* ]{2,}/
    ALT_TITLE_REGEX = License::ALT_TITLE_REGEX
    ALL_RIGHTS_RESERVED_REGEX = /#{START_REGEX}all rights reserved\.?$/i
    WHITESPACE_REGEX = /\s+/
    MARKDOWN_HEADING_REGEX = /\A\s*#+/
    VERSION_REGEX = /\Aversion.*$/i
    MARKUP_REGEX = /(?:[_*~`]+.*?[_*~`]+|^\s*>|\[.*?\]\(.*?\))/
    URL_REGEX = /#{START_REGEX}https?:\/\/[^ ]+/
    BULLET_REGEX = /\n\n\s*(?:[*-]|\(?[\da-z]{1,2}[)\.])\s+/i

    # Legally equivalent words that schould be ignored for comparison
    # See https://spdx.org/spdx-license-list/matching-guidelines
    VARIETAL_WORDS = {
      'acknowledgment'  => 'acknowledgement',
      'analogue'        => 'analog',
      'analyse'         => 'analyze',
      'artefact'        => 'artifact',
      'authorisation'   => 'authorization',
      'authorised'      => 'authorized',
      'calibre'         => 'caliber',
      'cancelled'       => 'canceled',
      'capitalisations' => 'capitalizations',
      'catalogue'       => 'catalog',
      'categorise'      => 'categorize',
      'centre'          => 'center',
      'emphasised'      => 'emphasized',
      'favour'          => 'favor',
      'favourite'       => 'favorite',
      'fulfil'          => 'fulfill',
      'fulfilment'      => 'fulfillment',
      'initialise'      => 'initialize',
      'judgment'        => 'judgement',
      'labelling'       => 'labeling',
      'labour'          => 'labor',
      'licence'         => 'license',
      'maximise'        => 'maximize',
      'modelled'        => 'modeled',
      'modelling'       => 'modeling',
      'offence'         => 'offense',
      'optimise'        => 'optimize',
      'organisation'    => 'organization',
      'organise'        => 'organize',
      'practise'        => 'practice',
      'programme'       => 'program',
      'realise'         => 'realize',
      'recognise'       => 'recognize',
      'signalling'      => 'signaling',
      'sub-license'     => 'sublicense',
      'sub license'     => 'sublicense',
      'utilisation'     => 'utilization',
      'whilst'          => 'while',
      'wilful'          => 'wilfull',
      'non-commercial'  => 'noncommercial',
      'cent'            => 'percent',
      'owner'           => 'holder'
    }.freeze

    # A set of each word in the license, without duplicates
    def wordset
      @wordset ||= if content_normalized
        content_normalized.scan(/[\w']+/).to_set
      end
    end

    # Number of characteres in the normalized content
    def length
      return 0 unless content_normalized
      content_normalized.length
    end

    # Number of characters that could be added/removed to still be
    # considered a potential match
    def max_delta
      @max_delta ||= (length * Licensee.inverse_confidence_threshold).to_i
    end

    # Given another license or project file, calculates the difference in length
    def length_delta(other)
      (length - other.length).abs
    end

    # Given another license or project file, calculates the similarity
    # as a percentage of words in common
    def similarity(other)
      overlap = (wordset & other.wordset).size
      total = wordset.size + other.wordset.size
      100.0 * (overlap * 2.0 / total)
    end

    # SHA1 of the normalized content
    def content_hash
      @content_hash ||= DIGEST.hexdigest content_normalized
    end

    # Content with the title and version removed
    # The first time should normally be the attribution line
    # Used to dry up `content_normalized` but we need the case sensitive
    # content with attribution first to detect attribuion in LicenseFile
    def content_without_title_and_version
      @content_without_title_and_version ||= begin
        string = content.strip
        string = strip_markdown_headings(string)
        string = strip_hrs(string)
        string = strip_title(string) while string =~ ContentHelper.title_regex
        strip_version(string).strip
      end
    end

    # Content without title, version, copyright, whitespace, or insturctions
    #
    # wrap - Optional width to wrap the content
    #
    # Returns a string
    def content_normalized(wrap: nil)
      return unless content
      @content_normalized ||= begin
        string = content_without_title_and_version.downcase
        %i[dashes quotes spelling copyright bullets ampersands].each do |operation|
          string = send("normalize_#{operation}", string)
        end

        while string =~ Matchers::Copyright::REGEX
          string = strip_copyright(string)
        end

        string, _partition, _instructions = string.partition(END_OF_TERMS_REGEX)

        %i[
          all_rights_reserved url borders markup whitespace
        ].each do |operation|
          string = send("strip_#{operation}", string)
        end

        string
      end

      if wrap.nil?
        @content_normalized
      else
        Licensee::ContentHelper.wrap(@content_normalized, wrap)
      end
    end

    # Wrap text to the given line length
    def self.wrap(text, line_width = 80)
      return if text.nil?
      text = text.clone
      text.gsub!(BULLET_REGEX) { |m| "\n#{m}\n" }
      text.gsub!(/([^\n])\n([^\n])/, '\1 \2')

      text = text.split("\n").collect do |line|
        if line =~ HR_REGEX
          line
        elsif line.length > line_width
          line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
        else
          line
        end
      end * "\n"

      text.strip
    end

    def self.format_percent(float)
      "#{format('%.2f', float)}%"
    end

    def self.title_regex
      licenses = Licensee::License.all(hidden: true, psuedo: false)
      titles = licenses.map(&:title_regex)

      # Title regex must include the version to support matching within
      # families, but for sake of normalization, we can be less strict
      without_versions = licenses.map do |license|
        next if license.title == license.name_without_version
        Regexp.new Regexp.escape(license.name_without_version), 'i'
      end
      titles.concat(without_versions.compact)

      /#{START_REGEX}\s*\(?(the )?#{Regexp.union titles}.*$/i
    end

    private

    
  end
end
