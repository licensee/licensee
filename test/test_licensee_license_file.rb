require 'helper'

class TestLicenseeLicenseFile < Minitest::Test

  def setup
    @repo = Rugged::Repository.new(fixture_path("licenses.git"))
    blob = 'bcb552d06d9cf1cd4c048a6d3bf716849c2216cc'
    @file = Licensee::LicenseFile.new(@repo.lookup(blob), :path => "LICENSE")
    @gpl = Licensee::Licenses.find "GPL-3.0"
    @mit = Licensee::Licenses.find "MIT"
  end

  should "read the file" do
    assert @file.contents =~ /MIT/
  end

  should "match the license" do
    assert_equal "mit", @file.match.key
  end

  should "know the path" do
    assert_equal "LICENSE", @file.path
  end

  should "diff the file" do
    expected = "-Copyright (c) [year] [fullname]\n+Copyright (c) 2014 Ben Balter"
    assert @file.diff.include?(expected)
  end

  should "calculate confidence" do
    assert_equal 94, @file.confidence
  end
end
