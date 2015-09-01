require 'helper'

class TestLicenseeLevenshteinMatcher < Minitest::Test

  def setup
    text = license_from_path( Licensee::License.find("mit").path )
    blob = FakeBlob.new(text)
    @mit = Licensee::ProjectFile.new(blob, "LICENSE")
  end

  should "match the license" do
    assert_equal "mit", Licensee::LevenshteinMatcher.match(@mit).key
  end

  should "know the match confidence" do
    matcher = Licensee::LevenshteinMatcher.new(@mit)
    assert matcher.confidence > 98, "#{matcher.confidence} < 98"
  end

  should "calculate max delta" do
    assert_equal 937.8000000000001, Licensee::LevenshteinMatcher.new(@mit).max_delta
  end

  should "calculate length delta" do
    isc = Licensee::License.find("isc")
    assert_equal 0.0, Licensee::LevenshteinMatcher.new(@mit).length_delta(Licensee::License.find("mit"))
    assert_equal 346.0, Licensee::LevenshteinMatcher.new(@mit).length_delta(isc)
  end

  should "round up potential licenses" do
    assert_equal 6, Licensee::LevenshteinMatcher.new(@mit).potential_licenses.size
  end

end
