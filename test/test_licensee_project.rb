require 'helper'

class TestLicenseeProject < Minitest::Test

  def setup
    @project = Licensee::Project.new fixture_path("simple")
  end

  should "detect the license file" do
    assert_equal Licensee::LicenseFile, @project.license_file.class
  end

  should "detect the license" do
    assert_equal "MIT", @project.license.name
  end
end
