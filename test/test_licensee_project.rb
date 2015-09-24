require 'helper'
require 'fileutils'

class TestLicenseeProject < Minitest::Test
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
        assert_equal expected, Licensee::Project.license_score(filename)
      end
    end
  end

  describe("git repository project") do
    def make_project(fixture_name)
      fixture = fixture_path fixture_name
      Licensee::Project.new fixture
    end

    should "detect the license file" do
      project = make_project "licenses.git"
      assert_instance_of Licensee::ProjectLicense, project.license_file
    end

    should "detect the license" do
      project = make_project "licenses.git"
      assert_equal "mit", project.license.key
    end

    should "detect an atypically cased license file" do
      project = make_project "case-sensitive.git"
      assert_instance_of Licensee::ProjectLicense, project.license_file
    end

    should "detect MIT-LICENSE licensed projects" do
      project = make_project "named-license-file-prefix.git"
      assert_equal "mit", project.license.key
    end

    should "detect LICENSE-MIT licensed projects" do
      project = make_project "named-license-file-suffix.git"
      assert_equal "mit", project.license.key
    end

    should "not error out on repos with folders names license" do
      project = make_project "license-folder.git"
      assert_equal nil, project.license
    end

    should "detect licence files" do
      project = make_project "licence.git"
      assert_equal "mit", project.license.key
    end

    should "detect an unlicensed project" do
      project = make_project "no-license.git"
      assert_equal nil, project.license
    end
  end

  describe "mit license with title removed" do
    should "detect the MIT license" do
      verify_license_file fixture_path("mit-without-title/mit.txt")
    end

    should "should detect the MIT license when rewrapped" do
      verify_license_file fixture_path("mit-without-title-rewrapped/mit.txt")
    end
  end


  describe "packages" do
    should "detect a package file" do
      project = Licensee::Project.new(fixture_path("npm"), detect_packages: true)
      assert_equal "mit", project.license.key
    end
  end
end
