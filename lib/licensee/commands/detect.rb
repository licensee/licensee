# frozen_string_literal: true

require_relative 'detect_helpers'

# Implementation of the `licensee detect` command.
class LicenseeCLI < Thor
  include Licensee::Commands::DetectCLIHelpers

  desc 'detect [PATH]', 'Detect the license of the given project'
  option :json, type: :boolean, desc: 'Return output as JSON'
  option :packages, type: :boolean, default: true, desc: 'Detect licenses in package manager files'
  option :readme, type: :boolean, default: true, desc: 'Detect licenses in README files'
  option :confidence, type: :numeric, default: Licensee.confidence_threshold, desc: 'Confidence threshold'
  option :license, type: :string, desc: 'The SPDX ID or key of the license to compare (implies --diff)'
  option :diff, type: :boolean, desc: 'Compare the license to the closest match'
  option :ref, type: :string, desc: 'The name of the commit/branch/tag to search (github.com only)'
  option :filesystem, type: :boolean, desc: 'Force looking at the filesystem (ignore git data)'
  option :recursive, type: :boolean, desc: 'Recursively detect licenses in subdirectories'
  option :depth, type: :numeric, default: 3, desc: 'Maximum directory depth for --recursive'
  def detect(_path = nil)
    Licensee.confidence_threshold = options[:confidence]

    if options[:recursive]
      handle_recursive_detect
    else
      handle_json_output if options[:json]
      print_project_summary
      print_matched_files
      maybe_diff_license_file
    end
  end

  private

  def handle_recursive_detect
    root = File.expand_path(path || Dir.pwd)
    results = collect_recursive_results(root, root, options[:depth])

    if options[:json]
      say results.map { |r| r[:project].to_h.merge(path: r[:path]) }.to_json
    else
      print_recursive_results(results)
    end

    exit(results.any? { |r| !r[:project].licenses.empty? })
  end

  def collect_recursive_results(root, current, remaining_depth)
    results = []
    add_recursive_project(root, current, results)
    return results if remaining_depth <= 0

    entries = begin
      Dir.children(current).sort
    rescue StandardError
      []
    end
    entries.each do |entry|
      full_path = File.join(current, entry)
      next unless File.directory?(full_path)

      results.concat(collect_recursive_results(root, full_path, remaining_depth - 1))
    end
    results
  end

  def add_recursive_project(root, full_path, results)
    proj = Licensee.project(full_path,
                            detect_packages: options[:packages],
                            detect_readme:   options[:readme])
    return if proj.licenses.empty?

    rel = Pathname.new(full_path).relative_path_from(Pathname.new(root)).to_s
    rel = '.' if rel == ''
    results << { path: rel, project: proj }
  end

  def print_recursive_results(results)
    if results.empty?
      say 'No licenses detected.'
      return
    end

    results.each do |result|
      license_ids = result[:project].licenses.map(&:spdx_id).join(', ')
      say "#{result[:path]}: #{license_ids}"
    end
  end
end
