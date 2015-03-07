# Pulled from helper.rb because something in the test suite monkey patches benchmarking

require 'securerandom'

def fixtures_base
  File.expand_path "fixtures", File.dirname( __FILE__ )
end

def fixture_path(fixture)
  File.expand_path fixture, fixtures_base
end

def license_from_path(path)
  license = File.open(path).read.split("---").last
  license.sub! "[fullname]", "Ben Balter"
  license.sub! "[year]", "2014"
  license.sub! "[email]", "ben@github.invalid"
  license
end

class FakeBlob
  attr_reader :content

  def initialize(content)
    @content = content
  end

  def size
    content.size
  end

  def similarity(other)
    self.hashsig ? Rugged::Blob::HashSignature.compare(self.hashsig, other) : 0
  end

  def hashsig(options = 0)
    @hashsig ||= Rugged::Blob::HashSignature.new(content, options)
  rescue Rugged::InvalidError
    nil
  end
end

def chaos_monkey(string)
  Random.rand(7).times do
    string[Random.rand(string.length)] = SecureRandom.base64(Random.rand(10))
  end
  string
end

def verify_license_file(license, chaos = false, wrap=false)
  expected = File.basename(license, ".txt")

  text = license_from_path(license)
  text = chaos_monkey(text) if chaos
  text = wrap(text, wrap) if wrap

  blob = FakeBlob.new(text)
  license_file = Licensee::LicenseFile.new(blob)

  actual = license_file.match
  assert actual, "No match for #{expected}."
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
