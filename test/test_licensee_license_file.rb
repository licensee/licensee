require 'helper'

class TestLicenseeLicenseFile < Minitest::Test

  def setup
    @file = Licensee::LicenseFile.find fixture_path("simple")
    @gpl = Licensee::Licenses.find "GPL-3.0"
    @mit = Licensee::Licenses.find "MIT"
  end

  should "read the file" do
    assert @file.contents =~ /MIT/
  end

  should "known the file length" do
    assert_equal 902, @file.length
  end

  should "calcualte length deltas" do
    assert_equal 3, @file.length_delta(@mit)
    assert_equal 27732, @file.length_delta(@gpl)
  end

  should "sort licenses by length delta" do
    Licensee::CONFIDENCE_THRESHOLD = "0".to_f
    assert_equal "mit", @file.licenses_sorted.first.name
    assert_equal "no-license", @file.licenses_sorted.last.name
  end

  should "calculate distance" do
    actual = @file.distance(@mit)
    assert actual > ".2".to_f, "expected #{actual} to be > .2 for MIT"
    actual = @file.distance(@gpl)
    assert actual < ".5".to_f, "expected #{actual} to be < .5 for GPL"
  end

  should "match the license" do
    assert_equal "mit", @file.match.name
  end

  should "match a txt license" do
    file = Licensee::LicenseFile.find fixture_path("txt")
    assert_equal "mit", file.match.name
  end

  should "match a md license" do
    file = Licensee::LicenseFile.find fixture_path("md")
    assert_equal "mit", file.match.name
  end

  should "diff the file" do
    expected = "-Copyright (c) [year] [fullname]\n+Copyright (c) 2014 Ben Balter"
    assert @file.diff.include?(expected)
  end
end
