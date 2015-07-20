require 'helper'

class TestLicenseeVendor < Minitest::Test
  Dir["#{Licensee::Licenses.base}/*"].shuffle.each do |license|

    should "detect the #{license} license" do
      verify_license_file(license)
    end

    context "when modified" do
      should "detect the #{license} license" do
        verify_license_file(license, true) unless license =~ /no-license\.txt$/
      end
    end

    context "different line lengths" do
      should "detect the #{license} license" do
        verify_license_file(license, false, 50)
      end

      context "when modified" do
        should "detect the #{license} license" do
          verify_license_file(license, true, 50) unless license =~ /no-license\.txt$/
        end
      end
    end
  end
end
