# frozen_string_literal: true

require 'tmpdir'

class LicenseeCLI < Thor
  desc 'diff [PATH]', 'Compare the given license text to a known license'
  option :license, type: :string, desc: 'The SPDX ID or key of the license to compare'
  def diff(_path = nil)
    say "Comparing to #{expected_license.name}:"
    print_table diff_summary_rows
    exit_on_exact_match
    say word_diff
  end

  private

  def diff_summary_rows
    [
      ['Input Length:', license_to_diff.length],
      ['License length:', expected_license.length],
      ['Similarity:', formatted_similarity]
    ]
  end

  def formatted_similarity
    similarity = expected_license.similarity(license_to_diff)
    Licensee::ContentHelper.format_percent(similarity)
  end

  def exit_on_exact_match
    return unless expected_text == input_text

    say 'Exact match!', :green
    exit
  end

  def expected_text
    @expected_text ||= expected_license.content_normalized(wrap: 80)
  end

  def input_text
    @input_text ||= license_to_diff.content_normalized(wrap: 80)
  end

  def word_diff
    Dir.mktmpdir { |dir| word_diff_in_dir(dir) }
  end

  def word_diff_in_dir(dir)
    path = File.expand_path 'LICENSE', dir
    Dir.chdir(dir) { git_word_diff(path) }
  end

  def git_word_diff(path)
    `git init`
    File.write(path, expected_text)
    `git add LICENSE`
    `git commit -m 'left'`
    File.write(path, input_text)
    `git diff --word-diff`
  end

  def license_to_diff
    return options[:license_to_diff] if options[:license_to_diff]
    return project.license_file if remote? || ($stdin.tty? && project.license_file)

    @license_to_diff ||= Licensee::ProjectFiles::LicenseFile.new($stdin.read, 'LICENSE')
  end

  def expected_license
    @expected_license ||= Licensee::License.find options[:license] if options[:license]
    return @expected_license if @expected_license

    if options[:license]
      error "#{options[:license]} is not a valid license"
    else
      error 'Usage: provide a license to diff against with --license (spdx name)'
    end

    error "Valid licenses: #{Licensee::License.all(hidden: true).map(&:key).join(', ')}"
    exit 1
  end
end
