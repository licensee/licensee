require 'helper'

class TestLicenseeProjectFile < Minitest::Test

  def setup
    @repo = Rugged::Repository.new(fixture_path("licenses.git"))
    blob, _ = Rugged::Blob.to_buffer(@repo, 'bcb552d06d9cf1cd4c048a6d3bf716849c2216cc')
    @file = Licensee::Project::LicenseFile.new(blob)
    @gpl = Licensee::License.find "GPL-3.0"
    @mit = Licensee::License.find "MIT"
  end

  should "read the file" do
    assert @file.content =~ /MIT/
  end

  should "match the license" do
    assert_equal "mit", @file.license.key
  end

  should "calculate confidence" do
    assert_equal 100, @file.confidence
  end

  should "parse the attribution" do
    assert_equal "Copyright (c) 2014 Ben Balter", @file.attribution
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

  context "readme filename scoring" do
    EXPECTATIONS = {
      "readme"      => 1.0,
      "README"      => 1.0,
      "readme.md"   => 0.9,
      "README.md"   => 0.9,
      "readme.txt"  => 0.9,
      "LICENSE"     => 0.0
    }

    EXPECTATIONS.each do |filename, expected|
      should "score a readme named `#{filename}` as `#{expected}`" do
        assert_equal expected, Licensee::Project::Readme.name_score(filename)
      end
    end

  end

  context "readme content" do
    should "be blank if not license text" do
      file = Licensee::Project::Readme.new("There is no License in this README")
      assert_equal "", file.content
    end

    should "get content after h1" do
      file = Licensee::Project::Readme.new("# License\n\nhello world")
      assert_equal "hello world", file.content
    end

    should "get content after h2" do
      file = Licensee::Project::Readme.new("## License\n\nhello world")
      assert_equal "hello world", file.content
    end

    should "be case-insensitive" do
      file = Licensee::Project::Readme.new("## LICENSE\n\nhello world")
      assert_equal "hello world", file.content
    end

    should "be british" do
      file = Licensee::Project::Readme.new("## Licence\n\nhello world")
      assert_equal "hello world", file.content
    end

    should "not include trailing content" do
      file = Licensee::Project::Readme.new("## License\n\nhello world\n\n# Contributing")
      assert_equal "hello world", file.content
    end
  end
end
