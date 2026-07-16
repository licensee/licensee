# frozen_string_literal: true

# Implementation of the `licensee scan` command.
class LicenseeCLI < Thor
  SCAN_SKIP_DIRS = %w[.git node_modules vendor .bundle].freeze

  desc 'scan [PATH]', 'Scan subdirectories of PATH for licenses'
  option :json, type: :boolean, desc: 'Return output as JSON'
  option :packages, type: :boolean, default: true, desc: 'Detect licenses in package manager files'
  option :readme, type: :boolean, default: true, desc: 'Detect licenses in README files'
  option :confidence, type: :numeric, default: Licensee.confidence_threshold, desc: 'Confidence threshold'
  option :depth, type: :numeric, default: 3, desc: 'Maximum directory depth to scan'
  def scan(path = nil) # rubocop:disable Metrics/AbcSize
    Licensee.confidence_threshold = options[:confidence]
    root = File.expand_path(path || Dir.pwd)

    results = scan_directory(root, options[:depth])

    if options[:json]
      say results.map { |r| r[:project].to_h.merge(path: r[:path]) }.to_json
    else
      print_scan_results(results)
    end

    exit(results.any? { |r| !r[:project].licenses.empty? })
  end

  private

  def scan_directory(root, max_depth)
    results = []
    collect_subdirs(root, root, max_depth, results)
    results
  end

  # rubocop:disable Metrics/MethodLength
  def collect_subdirs(root, current, remaining_depth, results)
    return if remaining_depth.negative?

    entries = begin
      Dir.children(current).sort
    rescue StandardError
      []
    end
    entries.each do |entry|
      next if SCAN_SKIP_DIRS.include?(entry)

      full_path = File.join(current, entry)
      next unless File.directory?(full_path)

      add_project_result(root, full_path, results)
      collect_subdirs(root, full_path, remaining_depth - 1, results)
    end
  end
  # rubocop:enable Metrics/MethodLength

  def add_project_result(root, full_path, results)
    project = Licensee.project(full_path,
                               detect_packages: options[:packages],
                               detect_readme:   options[:readme])
    results << { path: relative_path(root, full_path), project: project } unless project.licenses.empty?
  end

  def relative_path(root, full_path)
    Pathname.new(full_path).relative_path_from(Pathname.new(root)).to_s
  end

  def print_scan_results(results)
    if results.empty?
      say 'No licenses detected in subdirectories.'
      return
    end

    results.each do |result|
      license_ids = result[:project].licenses.map(&:spdx_id).join(', ')
      say "#{result[:path]}: #{license_ids}"
    end
  end
end
