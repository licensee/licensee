require 'helper'

class TestLicenseeGitMatcher < Minitest::Test

  def setup
    text = license_from_path( Licensee::Licenses.find("mit").path )
    blob = FakeBlob.new(text)
    @mit = Licensee::ProjectFile.new(blob, "LICENSE")
  end

  should "match the license" do
    assert_equal "mit", Licensee::GitMatcher.match(@mit).key
  end

  should "know the match confidence" do
    assert_equal 94, Licensee::GitMatcher.new(@mit).confidence
  end
end
