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
    assert_equal 1077, @file.length
  end

  should "calcualte length deltas" do
    assert_equal 4, @file.length_delta(@mit)
    assert_equal 34065, @file.length_delta(@gpl)
  end

  should "sort licenses by length delta" do
    assert_equal "mit", @file.licenses_sorted.first.name
    assert_equal "no-license", @file.licenses_sorted.last.name
  end

  should "calculate percent changed" do
    assert @file.percent_changed(@mit) < ".02".to_f
    assert @file.percent_changed(@gpl) > 30
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
