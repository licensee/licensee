require 'helper'
require 'fileutils'

class TestLicenseeProject < Minitest::Test

  [true, false].each do |as_git|
    describe(as_git ? "git" : "non-git") do

      def make_project(fixture_name, as_git)
        fixture = fixture_path fixture_name

        unless as_git
          dest = File.join("tmp", "fixtures", fixture_name)
          FileUtils.mkdir_p File.dirname(dest)
          system "git", "clone", "-q", fixture, dest
          FileUtils.rm_r File.join(dest, ".git")
          fixture = dest
        end

        Licensee::Project.new fixture
      end

      unless as_git
        def teardown
          FileUtils.rm_rf "tmp/fixtures"
        end
      end

      should "detect the license file" do
        project = make_project "licenses.git", as_git
        assert_instance_of Licensee::LicenseFile, project.license_file
      end

      should "detect the license" do
        project = make_project "licenses.git", as_git
        assert_equal "mit", project.license.key
      end

      should "return the license hash" do
        project = make_project "licenses.git", as_git
        assert_equal "LICENSE", project.send(:license_hash)[:name]
      end

      should "return the license blob" do
        project = make_project "licenses.git", as_git
        assert_equal 1077, project.send(:license_blob).size
      end

      should "return the license path" do
        project = make_project "licenses.git", as_git
        assert_equal "LICENSE", project.send(:license_path)
      end

      should "detect an atypically cased license file" do
        project = make_project "case-sensitive.git", as_git
        assert_instance_of Licensee::LicenseFile, project.license_file
      end

      should "detect MIT-LICENSE licensed projects" do
        project = make_project "named-license-file-prefix.git", as_git
        assert_equal "mit", project.license.key
      end

      should "detect LICENSE-MIT licensed projects" do
        project = make_project "named-license-file-suffix.git", as_git
        assert_equal "mit", project.license.key
      end

      should "not error out on repos with folders names license" do
        project = make_project "license-folder.git", as_git
        assert_equal nil, project.license
      end

      should "detect licence files" do
        project = make_project "licence.git", as_git
        assert_equal "mit", project.license.key
      end

      should "detect an unlicensed project" do
        project = make_project "no-license.git", as_git
        assert_equal nil, project.license
      end
    end
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
        assert_equal expected, Licensee::Project.match_license_file(filename)
      end
    end
  end
end
