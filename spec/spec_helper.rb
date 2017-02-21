require 'coveralls'
Coveralls.wear!

require 'licensee'
require 'open3'
require 'tmpdir'

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed
end

def project_root
  File.expand_path '../', File.dirname(__FILE__)
end

def fixtures_base
  File.expand_path 'spec/fixtures', project_root
end

def fixture_path(fixture)
  File.expand_path fixture, fixtures_base
end

def sub_copyright_info(text)
  text.sub! '[fullname]', 'Ben Balter'
  text.sub! '[year]', '2016'
  text.sub! '[email]', 'ben@github.invalid'
  text
end

def wrap(text, line_width = 80)
  text = text.clone
  text.gsub!(/([^\n])\n([^\n])/, '\1 \2')

  text = text.split("\n").collect do |line|
    if line.length > line_width
      line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
    else
      line
    end
  end * "\n"

  text.strip
end

# Add random words to the end of a license to test similarity tollerances
def add_random_words(string, count = 5)
  string = string.dup
  ipsum = %w(lorem ipsum dolor sit amet consectetur adipiscing elit)
  count.times do
    string << " #{ipsum[Random.rand(ipsum.length)]}"
  end
  string
end

def git_init(path)
  Dir.chdir path do
    `git init`
    `git config --global commit.gpgsign false`
    `git add .`
    `git commit -m 'initial commit'`
  end
end

def format_percent(float)
  "#{format('%.2f', float)}%"
end

RSpec::Matchers.define :be_an_existing_file do
  match { |path| File.exist?(path) }
end

RSpec::Matchers.define :be_detected_as do |expected|
  match do |actual|
    @expected_as_array = [expected.content]
    license_file = Licensee::Project::LicenseFile.new(actual, 'LICENSE')
    return false unless license_file.license
    values_match? expected, license_file.license
  end

  failure_message do |actual|
    license_file = Licensee::Project::LicenseFile.new(actual, 'LICENSE')
    license_name = expected.meta['spdx-id'] || expected.key
    similarity = expected.similarity(license_file)
    msg = "Expected the content to match the #{license_name} license"
    msg << " (#{format_percent(similarity)} similarity"
    msg << "using the #{licese_file.matcher} matcher)"
  end

  failure_message_when_negated do |actual|
    license_file = Licensee::Project::LicenseFile.new(actual, 'LICENSE')
    license_name = expected.meta['spdx-id'] || expected.key
    similarity = expected.similarity(license_file)
    msg = "Expected the content to *not* match the #{license_name} license"
    msg << " (#{format_percent(similarity)} similarity)"
  end

  diffable
end
