require 'helper'

class TestLicenseeExactMatcher < Minitest::Test
  def setup
    text = File.open(Licensee::License.find("mit").path).read.split("---").last
    @mit = Licensee::Project::LicenseFile.new(text)
  end

  should "match the license" do
    assert_equal "mit", Licensee::Matcher::Exact.new(@mit).match.key
  end

  should "know the match confidence" do
    assert_equal 100, Licensee::Matcher::Exact.new(@mit).confidence
  end
end
