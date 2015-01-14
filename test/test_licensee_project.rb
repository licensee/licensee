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
end
