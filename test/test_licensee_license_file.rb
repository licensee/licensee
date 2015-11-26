require 'helper'

class TestLicenseeLicenseFile < Minitest::Test
  def setup
    @repo = Rugged::Repository.new(fixture_path("licenses.git"))
    blob, _ = Rugged::Blob.to_buffer(@repo, 'bcb552d06d9cf1cd4c048a6d3bf716849c2216cc')
    @file = Licensee::Project::LicenseFile.new(blob)
  end

  context "content" do
    should "parse the attribution" do
      assert_equal "Copyright (c) 2014 Ben Balter", @file.attribution
    end

    should "not choke on non-UTF-8 licenses" do
      text = "\x91License\x93".force_encoding('windows-1251')
      file = Licensee::Project::LicenseFile.new(text)
      assert_equal nil, file.attribution
    end

    should "create the wordset" do
      assert_equal 93, @file.wordset.count
      assert_equal "the", @file.wordset.first
    end

    should "create the hash" do
      assert_equal "44a042145f04777012c38c161533ca67a73dfc1e", @file.hash
    end
  end

  context "license filename scoring" do
    EXPECTATIONS = {
      "license"            => 1.0,
      "LICENCE"            => 1.0,
      "unLICENSE"          => 1.0,
      "unlicence"          => 1.0,
      "license.md"         => 0.9,
      "LICENSE.md"         => 0.9,
      "license.txt"        => 0.9,
      "COPYING"            => 0.8,
      "copyRIGHT"          => 0.8,
      "COPYRIGHT.txt"      => 0.8,
      "LICENSE.php"        => 0.7,
      "LICENSE-MIT"        => 0.5,
      "MIT-LICENSE.txt"    => 0.5,
      "mit-license-foo.md" => 0.5,
      "README.txt"         => 0.0
    }

    EXPECTATIONS.each do |filename, expected|
      should "score a license named `#{filename}` as `#{expected}`" do
        assert_equal expected, Licensee::Project::LicenseFile.name_score(filename)
      end
    end
  end
end
