# frozen_string_literal: true

module Licensee
  module Matchers
    # Detects licenses contained within compound (multi-license) files using
    # a word-coverage pre-filter and a word-anchored sliding-window search.
    #
    # Algorithm (per candidate license L):
    #
    # 1. Coverage pre-filter: skip L if fewer than minimum_coverage of L's unique
    #    words appear anywhere in the file. The threshold is derived from
    #    confidence_threshold so that candidates mathematically unable to satisfy it
    #    are skipped without wasteful window searches.
    #
    # 2. Anchor-based window search: for each word position where a word from L
    #    appears in the file, expand a window rightward, tracking the unique wordset
    #    of the window. Stop expanding when the unique wordset exceeds
    #    LICENSE_WORDSET_MULTIPLIER × |L.wordset| + WINDOW_SLACK. Record the best
    #    (highest) Dice similarity seen for any window started at this anchor.
    #
    # 3. Report L as a compound match if any window achieves similarity ≥
    #    Licensee.confidence_threshold.
    #
    # This matcher is only invoked when the standard Dice matcher fails to find
    # a match. It is intentionally not run on very large files (> MAX_WORDS words)
    # to keep runtime bounded.
    #
    # +compound_matches+ returns all detected licenses sorted by confidence, as
    # an array of [Licensee::License, Float] pairs. +match+ and +confidence+
    # delegate to the top compound match for compatibility with the standard
    # matcher API.
    #
    # Like the standard Dice matcher, CompoundDice uses wordset_fieldless (the
    # license wordset minus template field placeholders such as [year] and
    # [fullname]) when computing window similarity. This ensures that rendered
    # files (with real copyright info) score correctly.
    #
    # Note: unlike the standard Dice matcher, CompoundDice does NOT apply a
    # bigram-similarity floor against the whole file. In a compound file the
    # target license occupies only a fraction of the content, so its bigrams score
    # poorly against the full text. The window-search already enforces locality.
    class CompoundDice < Licensee::Matchers::Matcher
      # Maximum size (as a multiple of the license unique wordset) of a candidate
      # window's unique wordset. Windows wider than this are abandoned.
      LICENSE_WORDSET_MULTIPLIER = 1.2

      # Fixed slack added to the max-unique-word cap so that licenses with very
      # small wordsets (< 30 unique words) still get a reasonable window.
      WINDOW_SLACK = 20

      # Maximum number of word-anchored start positions tried per license.
      # Positions are evenly sampled from all license-word positions in the file.
      MAX_STARTS = 200

      # Files larger than this word count are not processed (performance guard).
      MAX_WORDS = 5000

      # If the best window spans at least this fraction of the file's total words,
      # the match is suppressed. Modified single-license files (near-misses) have a
      # best window covering 98–100 % of the file; genuine compound-file windows
      # cover at most ~90 %. The threshold of 0.93 gives comfortable separation.
      MAX_WINDOW_COVERAGE = 0.93

      def name
        :compound_dice
      end

      def match
        @match ||= compound_matches.first&.first
      end

      def confidence
        @confidence ||= compound_matches.first&.last || 0
      end

      # Returns all licenses detected within the file as compound matches,
      # sorted by descending similarity. Each element is a two-element array
      # [Licensee::License, Float].
      def compound_matches
        @compound_matches ||= compute_compound_matches
      end

      private

      def compute_compound_matches
        file_words = words
        return [] if file_words.nil? || file_words.empty?
        return [] if file_words.size > MAX_WORDS

        file_wordset = file_words.to_set
        potential_licenses
          .filter_map { |lic| compound_match(lic, file_words, file_wordset) }
          .sort_by { |pair| -pair.last }
      end

      def words
        @words ||= file.content_normalized&.scan(%r{(?:[\w/-](?:'s|(?<=s)')?)+})
      end

      def potential_licenses
        Licensee.licenses(hidden: true, pseudo: false).reject do |license|
          license.creative_commons? && file.potential_false_positive?
        end
      end

      # Minimum fraction of a license's unique words that must appear anywhere in
      # the file before window search is attempted. Derived from confidence_threshold
      # so that candidates mathematically incapable of passing are skipped: the best
      # possible window Dice score for a candidate with coverage c is 2c/(1+c), and
      # for that to reach the confidence threshold t the required coverage is
      # c >= t/(200-t).
      def minimum_coverage
        Licensee.confidence_threshold / (200.0 - Licensee.confidence_threshold)
      end

      # Evaluate a single license against the file. Returns [license, sim] if the
      # license passes all checks, or nil to be filtered by filter_map.
      #
      # Uses wordset_fieldless (excluding template field placeholders such as
      # [year] and [fullname]) to match the behaviour of the standard Dice
      # matcher, which also excludes field words from similarity computation.
      # Without this, field words in the license wordset inflate the denominator
      # while never appearing in rendered files, lowering similarity below the
      # confidence threshold even for exact-match license sections.
      def compound_match(license, file_words, file_wordset)
        # Use fieldless wordset (strips template fields like [year]/[fullname])
        # so that rendered files (with real copyright info) score correctly.
        wordset = license.send(:wordset_fieldless)
        return unless wordset&.any?

        # Step 1: coverage pre-filter — skip if fewer than minimum_coverage fraction
        # of the license's unique words appear anywhere in the file. The threshold is
        # derived from confidence_threshold so that candidates mathematically unable
        # to satisfy it are skipped without wasteful window searches.
        coverage = (wordset & file_wordset).size.to_f / wordset.size
        return if coverage < minimum_coverage

        # Step 2: anchor-based window search
        sim = best_window_similarity(file_words, wordset)
        return unless sim >= Licensee.confidence_threshold

        [license, sim]
      end

      # Returns the highest Dice similarity achieved by any word-anchored window
      # for the given license wordset, or 0 if the window search finds nothing
      # above zero or if the best window covers too large a fraction of the file
      # (which indicates a near-miss modified single license rather than a true
      # compound file).
      def best_window_similarity(file_words, license_wordset)
        lic_positions = file_words.each_index.select { |i| license_wordset.include?(file_words[i]) }
        return 0.0 if lic_positions.empty?

        max_unique = (license_wordset.size * LICENSE_WORDSET_MULTIPLIER).ceil + WINDOW_SLACK
        sim, start, stop = best_window_range(file_words, license_wordset, lic_positions, max_unique)
        # Suppress matches whose best window spans nearly the whole file.
        # Modified single-license files score 98–100 % coverage; genuine compound
        # file components score ≤ 90 %. MAX_WINDOW_COVERAGE separates the two.
        (stop - start + 1).to_f / file_words.size >= MAX_WINDOW_COVERAGE ? 0.0 : sim
      end

      # Return [best_sim, best_start, best_end] across all sampled start positions.
      def best_window_range(file_words, license_wordset, lic_positions, max_unique)
        stride = [(lic_positions.size.to_f / MAX_STARTS).ceil, 1].max
        starts = lic_positions.select.with_index { |_p, i| (i % stride).zero? }
        starts.reduce([0.0, 0, file_words.size - 1]) do |best, start_pos|
          sim, end_pos = window_from(file_words, license_wordset, start_pos, max_unique)
          sim > best[0] ? [sim, start_pos, end_pos] : best
        end
      end

      # Expand a window rightward from +start_pos+, tracking unique words.
      # Returns [best_sim, best_end_index] for this window.
      def window_from(file_words, license_wordset, start_pos, max_unique)
        window_set = Set.new
        best = [0.0, start_pos]
        overlap = 0
        start_pos.upto(file_words.size - 1) do |j|
          overlap, full = expand_word(file_words[j], window_set, license_wordset, overlap, max_unique)
          break if full

          best = update_best(best, overlap, j, license_wordset, window_set)
          break if overlap == license_wordset.size
        end
        best
      end

      # Compute Dice similarity for current window and return updated +best+
      # if the new similarity is higher, or +best+ unchanged otherwise.
      def update_best(best, overlap, pos, license_wordset, window_set)
        sim = overlap * 200.0 / (license_wordset.size + window_set.size)
        sim > best[0] ? [sim, pos] : best
      end

      # Add +word+ to +window_set+, incrementing +overlap+ if word is in the
      # license. Returns [new_overlap, window_full?]. If word is already in the
      # set, returns unchanged values and false.
      def expand_word(word, window_set, license_wordset, overlap, max_unique)
        return [overlap, false] if window_set.include?(word)

        window_set.add(word)
        overlap += 1 if license_wordset.include?(word)
        [overlap, window_set.size > max_unique]
      end
    end
  end
end
