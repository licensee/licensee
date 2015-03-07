require 'helper'

class TestLicenseeVendor < Minitest::Test
  should "detect each vendored license" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      verify_license_file(license)
    end
  end

  should "detect each vendored license when modified" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      verify_license_file(license, true) unless license =~ /no-license\.txt$/
    end
  end

  should "detect each vendored license with different line lengths" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      verify_license_file(license, false, 50)
    end
  end

  should "detect each vendored license with different line lengths when modified" do
    licenses = Dir["#{Licensee::Licenses.base}/*"].shuffle
    licenses.each do |license|
      verify_license_file(license, true, 50) unless license =~ /no-license\.txt$/
    end
  end
end
