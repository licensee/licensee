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

def chaos_monkey(string)
  Random.rand(25).times do
    string[Random.rand(string.length)] = SecureRandom.base64(Random.rand(10))
  end
  string
end

def verify_license_file(license, chaos_monkey = false)
  expected = File.basename(license, ".txt")

  return if chaos_monkey && expected == "no-license"

  license_file = Licensee::LicenseFile.new
  license_file.contents = license_from_path(license)

  license_file.contents = chaos_monkey(license_file.contents) if chaos_monkey

  actual = license_file.matches.first
  assert actual, "No match for #{expected}."
  assert_equal expected, actual.name, "expeceted #{expected} but got #{actual.name} for .matches.first"

  actual = license_file.match
  assert actual, "No match for #{expected}."
  assert_equal expected, actual.name, "expeceted #{expected} but got #{actual.name} for .match. Confidence: #{actual.match}"
end
