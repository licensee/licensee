require 'helper'

class TestLicenseeProject < Minitest::Test

  def setup
    @project = Licensee::Project.new fixture_path("licenses.git")
  end

  should "detect the license file" do
    assert_equal Licensee::LicenseFile, @project.license_file.class
  end

  should "detect the license" do
    assert_equal "mit", @project.license.key
  end

  should "detect an atypically cased license file" do
    project = Licensee::Project.new fixture_path("case-sensitive.git")
    assert_equal Licensee::LicenseFile, project.license_file.class
  end

  should "detect MIT-LICENSE licensed projects" do
    project = Licensee::Project.new fixture_path("named-license-file-prefix.git")
    assert_equal "mit", project.license.key
  end

  should "detect LICENSE-MIT licensed projects" do
    project = Licensee::Project.new fixture_path("named-license-file-suffix.git")
    assert_equal "mit", project.license.key
  end

  should "not error out on repos with folders names license" do
    project = Licensee::Project.new fixture_path("license-folder.git")
    assert_equal nil, project.license
  end
end
