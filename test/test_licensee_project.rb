require 'helper'

class TestLicenseeProject < Minitest::Test

  def setup
    @project = Licensee::Project.new fixture_path("licenses.git")
  end

  should "detect the license file" do
    assert_equal Licensee::LicenseFile, @project.license_file.class
  end

  should "detect the license" do
    assert_equal "mit", @project.license.name
  end
end
