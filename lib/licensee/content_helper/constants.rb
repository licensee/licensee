# frozen_string_literal: true

module Licensee
  module ContentHelper
    module Constants
      DIGEST = Digest::SHA1
      START_REGEX = /\A\s*/
      END_OF_TERMS_REGEX = /^[\s#*_]*end of (the )?terms and conditions[\s#*_]*$/i
      REGEXES = {
        bom:                 /#{START_REGEX}\xEF\xBB\xBF/,
        hrs:                 /^\s*[=\-*]{3,}\s*$/,
        all_rights_reserved: /#{START_REGEX}all rights reserved\.?$/i,
        whitespace:          /\s+/,
        markdown_headings:   /^\s*#+/,
        version:             /#{START_REGEX}version.*$/i,
        span_markup:         /[_*~]+(.*?)[_*~]+/,
        link_markup:         /\[(.+?)\]\(.+?\)/,
        block_markup:        /^\s*>/,
        border_markup:       /^[*-](.*?)[*-]$/,
        comment_markup:      %r{^\s*?[/*]{1,2}},
        url:                 %r{#{START_REGEX}https?://[^ ]+\n},
        bullet:              /\n\n\s*(?:[*-]|\(?[\da-z]{1,2}[).])\s+/i,
        developed_by:        /#{START_REGEX}developed by:.*?\n\n/im,
        cc_dedication:       /The\s+text\s+of\s+the\s+Creative\s+Commons.*?Public\s+Domain\s+Dedication\./im,
        cc_wiki:             /wiki\.creativecommons\.org/i,
        cc_legal_code:       /^\s*Creative Commons Legal Code\s*$/i,
        cc0_info:            /For more information, please see\s*\S+zero\S+/im,
        cc0_disclaimer:      /CREATIVE COMMONS CORPORATION.*?\n\n/im,
        unlicense_info:      /For more information, please.*\S+unlicense\S+/im,
        mit_optional:        /\(including the next paragraph\)/i
      }.freeze

      NORMALIZATIONS = {
        lists:      { from: /^\s*(?:\d\.|[*-])(?: [*_]{0,2}\(?[\da-z]\)[*_]{0,2})?\s+([^\n])/, to: '- \1' },
        https:      { from: /http:/, to: 'https:' },
        ampersands: { from: '&', to: 'and' },
        dashes:     { from: /(?<!^)([—–-]+)(?!$)/, to: '-' },
        quote:      { from: /[`'"‘“’”]/, to: "'" },
        hyphenated: { from: /(\w+)-\s*\n\s*(\w+)/, to: '\\1-\\2' }
      }.freeze

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
        'per cent'        => 'percent',
        'copyright owner' => 'copyright holder'
      }.freeze

      STRIP_METHODS = %i[
        bom
        cc_optional
        cc0_optional
        unlicense_optional
        borders
        title
        version
        url
        copyright
        title
        block_markup
        developed_by
        end_of_terms
        whitespace
        mit_optional
      ].freeze
    end
  end
end
