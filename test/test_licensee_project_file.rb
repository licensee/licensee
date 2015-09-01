require 'helper'

class TestLicenseeProjectFile < Minitest::Test

  def setup
    @repo = Rugged::Repository.new(fixture_path("licenses.git"))
    blob = 'bcb552d06d9cf1cd4c048a6d3bf716849c2216cc'
    @file = Licensee::ProjectFile.new(@repo.lookup(blob), "LICENSE")
    @gpl = Licensee::License.find "GPL-3.0"
    @mit = Licensee::License.find "MIT"
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
    assert_equal 100, @file.confidence
  end

  context "license filename scoring" do

    EXPECTATIONS = {
      "license"            => 1.0,
      "LICENCE"            => 1.0,
      "license.md"         => 1.0,
      "LICENSE.md"         => 1.0,
      "license.txt"        => 1.0,
      "unLICENSE"          => 1.0,
      "unlicence"          => 1.0,
      "COPYING"            => 0.75,
      "copyRIGHT"          => 0.75,
      "COPYRIGHT.txt"      => 0.75,
      "LICENSE-MIT"        => 0.5,
      "MIT-LICENSE.txt"    => 0.5,
      "mit-license-foo.md" => 0.5,
      "README.txt"         => 0.0
    }

    EXPECTATIONS.each do |filename, expected|
      should "score a license named `#{filename}` as `#{expected}`" do
        assert_equal expected, Licensee::ProjectFile.license_score(filename)
      end
    end
  end
end
