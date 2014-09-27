require 'helper'

class TestLicenseeVendor < Minitest::Test
  should "detect each vendored license" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      expected = File.basename(license, ".txt")

      license_file = Licensee::LicenseFile.new
      license_file.contents = File.open(license).read.split("---").last
      actual = license_file.match

      assert actual, "No match for #{expected}."
      assert_equal expected, actual.name, "expeceted #{expected} but got #{actual.name}"
    end
  end
end
