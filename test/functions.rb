# Pulled from helper.rb because something in the test suite monkey patches benchmarking

require 'securerandom'
require_relative '../lib/licensee'

def fixtures_base
  File.expand_path 'fixtures', File.dirname(__FILE__)
end

def fixture_path(fixture)
  File.expand_path fixture, fixtures_base
end

def license_from_path(path)
  license = File.open(path).read.match(/\A(---\n.*\n---\n+)?(.*)/m).to_a[2]
  license.sub! '[fullname]', 'Ben Balter'
  license.sub! '[year]', '2014'
  license.sub! '[email]', 'ben@github.invalid'
  license
end

def chaos_monkey(string)
  Random.rand(3).times do
    string[Random.rand(string.length)] = SecureRandom.base64(Random.rand(3))
  end
  string
end

def verify_license_file(license, chaos = false, wrap = false)
  expected = File.basename(license, '.txt')

  text = license_from_path(license)
  text = chaos_monkey(text) if chaos
  text = wrap(text, wrap) if wrap

  license_file = Licensee::Project::LicenseFile.new(text)

  actual = license_file.license
  msg = "No match for #{expected}."

  assert actual, msg

  msg = "Expeceted #{expected} but got #{actual.key} for .match. "
  msg << "Confidence: #{license_file.confidence}. "
  msg << "Method: #{license_file.matcher.class}"
  assert_equal expected, actual.key, msg
end

def wrap(text, line_width = 80)
  text = text.clone
  copyright = /^#{Licensee::Matchers::Copyright::REGEX}$/i.match(text)
  if copyright
    text.gsub!(/^#{Licensee::Matchers::Copyright::REGEX}$/i, '[COPYRIGHT]')
  end
  text.gsub!(/([^\n])\n([^\n])/, '\1 \2')

  text = text.split("\n").collect do |line|
    if line.length > line_width
      line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip
    else
      line
    end
  end * "\n"
  text.gsub! '[COPYRIGHT]', "\n#{copyright}\n" if copyright
  text.strip
end
