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
    Rugged::Blob::HashSignature.compare(self.hashsig, other)
  end

  def hashsig(options = 0)
    @hashsig ||= Rugged::Blob::HashSignature.new(content, options)
  end
end

def chaos_monkey(string)
  lines = string.each_line.to_a

  Random.rand(5).times do
    lines[Random.rand(lines.size)] = SecureRandom.base64(Random.rand(80)) + "\n"
  end

  lines.join('')
end

def verify_license_file(license, chaos = false)
  expected = File.basename(license, ".txt")

  text = license_from_path(license)
  blob = FakeBlob.new(chaos ? chaos_monkey(text) : text)
  license_file = Licensee::LicenseFile.new(blob)

  actual = license_file.match
  assert actual, "No match for #{expected}."
  assert_equal expected, actual.name, "expeceted #{expected} but got #{actual.name} for .match. Matches: #{license_file.matches}"
end
