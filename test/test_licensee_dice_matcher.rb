require 'helper'

class TestLicenseeDiceMatcher < Minitest::Test
  def setup
    text = license_from_path(Licensee::License.find("mit").path)
    @mit = Licensee::Project::LicenseFile.new(text)
  end

  should "match the license" do
    assert_equal "mit", Licensee::Matcher::Dice.new(@mit).match.key
  end

  should "know the match confidence" do
    matcher = Licensee::Matcher::Dice.new(@mit)
    assert matcher.confidence > 95, "#{matcher.confidence} < 95"
  end

  should "calculate max delta" do
    assert_equal 83.7, Licensee::Matcher::Dice.new(@mit).max_delta
  end
end
