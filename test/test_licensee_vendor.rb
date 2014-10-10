require 'helper'

class TestLicenseeVendor < Minitest::Test
  should "detect each vendored license" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      verify_license_file(license)
    end
  end

  should "detect each vendored license" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      verify_license_file(license, true)
    end
  end

  should "detect each vendored license with different line lengths" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      verify_license_file(license, false, 70)
    end
  end
end
