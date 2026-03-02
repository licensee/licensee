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
  def detect(_path = nil)
    Licensee.confidence_threshold = options[:confidence]

    handle_json_output if options[:json]

    print_project_summary
    print_matched_files
    maybe_diff_license_file
  end
end
