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

  should "calcualte length deltas" do
    assert_equal 172, @file.length_delta(@mit)
    assert_equal 27557, @file.length_delta(@gpl)
  end

  should "calculate distance" do
    actual = @file.distance(@mit)
    assert actual > 2, "expected #{actual} to be > 2% for MIT"
    actual = @file.distance(@gpl)
    assert actual < 50, "expected #{actual} to be < 50% for GPL"
  end

  should "match the license" do
    assert_equal "mit", @file.match.name
  end

  if false
    should "diff the file" do
      expected = "-Copyright (c) [year] [fullname]\n+Copyright (c) 2014 Ben Balter"
      assert @file.diff.include?(expected)
    end
  end
end
