require 'helper'

class TestLicenseeLicenseFile < Minitest::Test

  def setup
    @repo = Rugged::Repository.new(fixture_path("licenses.git"))
    blob = 'bcb552d06d9cf1cd4c048a6d3bf716849c2216cc'
    @file = Licensee::LicenseFile.new(@repo.lookup(blob))
    @gpl = Licensee::Licenses.find "GPL-3.0"
    @mit = Licensee::Licenses.find "MIT"
  end

  should "read the file" do
    assert @file.contents =~ /MIT/
  end

  should "known the file length" do
    assert_equal 1077, @file.length
  end

  should "calculate similiarty" do
    actual = @file.send(:calculate_similarity, @mit)
    assert actual > Licensee::CONFIDENCE_THRESHOLD, "expected #{actual} to be > 90% for MIT"
    actual = @file.send(:calculate_similarity, @gpl)
    assert actual < 1, "expected #{actual} to be < 1% for GPL"
  end

  should "match the license" do
    assert_equal "mit", @file.match.name
  end

  should "diff the file" do
    expected = "-Copyright (c) [year] [fullname]\n+Copyright (c) 2014 Ben Balter"
    assert @file.diff.include?(expected)
  end
end
