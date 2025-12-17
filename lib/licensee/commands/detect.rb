# frozen_string_literal: true

class LicenseeCLI < Thor
  # Methods to call when displaying information about ProjectFiles
  MATCHED_FILE_METHODS = %i[
    content_hash attribution confidence matcher license
  ].freeze

  desc 'detect [PATH]', 'Detect the license of the given project'
  option :json, type: :boolean, desc: 'Return output as JSON'
  option :packages, type: :boolean, default: true, desc: 'Detect licenses in package manager files'
  option :readme, type: :boolean, default: true, desc: 'Detect licenses in README files'
  option :confidence, type: :numeric, default: Licensee.confidence_threshold, desc: 'Confidence threshold'
  option :license, type: :string, desc: 'The SPDX ID or key of the license to compare (implies --diff)'
  option :diff, type: :boolean, desc: 'Compare the license to the closest match'
  option :ref, type: :string, desc: 'The name of the commit/branch/tag to search (github.com only)'
  option :filesystem, type: :boolean, desc: 'Force looking at the filesystem (ignore git data)'
  def detect(_path = nil)
    Licensee.confidence_threshold = options[:confidence]

    handle_json_output if options[:json]

    print_project_summary
    print_matched_files
    maybe_diff_license_file

    exit !project.licenses.empty?
  end

  private

  # Given a string or object, prepares it for output and human consumption
  def humanize(value, type = nil)
    case type
    when :license
      value.spdx_id
    when :matcher
      value.class
    when :confidence
      Licensee::ContentHelper.format_percent(value)
    when :method
      "#{value.to_s.tr('_', ' ').capitalize}:"
    else
      value
    end
  end

  def licenses_by_similarity(matched_file)
    matcher = Licensee::Matchers::Dice.new(matched_file)
    potential_licenses = Licensee.licenses(hidden: true).select(&:wordset)
    matcher.instance_variable_set(:@potential_licenses, potential_licenses)
    matcher.licenses_by_similarity
  end

  def closest_license_key(matched_file)
    licenses = licenses_by_similarity(matched_file)
    licenses.first.first.key unless licenses.empty?
  end

  def handle_json_output
    say project.to_h.to_json
    exit !project.licenses.empty?
  end

  def print_project_summary
    rows = [license_summary_row]
    matched_files_row = matched_files_summary_row
    rows << matched_files_row if matched_files_row
    print_table rows
  end

  def license_summary_row
    if project.license
      ['License:', project.license.spdx_id]
    elsif !project.licenses.empty?
      ['Licenses:', project.licenses.map(&:spdx_id)]
    else
      ['License:', set_color('None', :red)]
    end
  end

  def matched_files_summary_row
    return if project.matched_files.empty?

    ['Matched files:', project.matched_files.map(&:filename).join(', ')]
  end

  def print_matched_files
    project.matched_files.each do |matched_file|
      print_matched_file_summary(matched_file)
      print_closest_non_matching_licenses(matched_file)
    end
  end

  def print_matched_file_summary(matched_file)
    rows = []
    say "#{matched_file.filename}:"

    MATCHED_FILE_METHODS.each do |method|
      next unless matched_file.respond_to? method

      value = matched_file.public_send method
      next if value.nil?

      rows << [humanize(method, :method), humanize(value, method)]
    end

    print_table rows, indent: 2
  end

  def print_closest_non_matching_licenses(matched_file)
    return unless matched_file.is_a?(Licensee::ProjectFiles::LicenseFile)
    return if matched_file.confidence == 100

    licenses = licenses_by_similarity(matched_file)
    return if licenses.empty?

    say '  Closest non-matching licenses:'
    rows = licenses[0...3].map do |license, similarity|
      spdx_id = license.meta['spdx-id']
      percent = Licensee::ContentHelper.format_percent(similarity)
      ["#{spdx_id} similarity:", percent]
    end
    print_table rows, indent: 4
  end

  def maybe_diff_license_file
    return unless project.license_file
    return unless options[:license] || options[:diff]

    license = options[:license] || closest_license_key(project.license_file)
    return unless license

    invoke(:diff, nil, license: license, license_to_diff: project.license_file)
  end
end
