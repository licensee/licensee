# Pulled from helper.rb because something in the test suite monkey patches benchmarking

require 'securerandom'
require_relative '../lib/licensee'

def fixtures_base
  File.expand_path "fixtures", File.dirname( __FILE__ )
end

def fixture_path(fixture)
  File.expand_path fixture, fixtures_base
end

def license_from_path(path)
  license = File.open(path).read.match(/\A(---\n.*\n---\n+)?(.*)/m).to_a[2]
  license.sub! "[fullname]", "Ben Balter"
  license.sub! "[year]", "2014"
  license.sub! "[email]", "ben@github.invalid"
  license
end

FakeBlob = Licensee::FilesystemRepository::Blob

def chaos_monkey(string)
  Random.rand(3).times do
    string[Random.rand(string.length)] = SecureRandom.base64(Random.rand(3))
  end
  string
end

def verify_license_file(license, chaos = false, wrap=false)
  expected = File.basename(license, ".txt")

  text = license_from_path(license)
  text = chaos_monkey(text) if chaos
  text = wrap(text, wrap) if wrap

  blob = FakeBlob.new(text)
  license_file = Licensee::ProjectFile.new(blob, "LICENSE")

  actual = license_file.match
  assert actual, "No match for #{expected}. Here's the test text:\n#{text}"
  assert_equal expected, actual.key, "expeceted #{expected} but got #{actual.key} for .match. Confidence: #{license_file.confidence}. Method: #{license_file.matcher.class}"
end

def wrap(text, line_width=80)
  text = text.clone
  text.gsub! /([^\n])\n([^\n])/, '\1 \2'
  text = text.split("\n").collect do |line|
    line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
  end * "\n"
  text.strip
end
