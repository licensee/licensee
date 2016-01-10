require 'helper'

class TestLicenseeVendor < Minitest::Test
  SKIP = %(wtfpl no-license).freeze

  Licensee::License.send(:license_files).shuffle.each do |license|
    should "detect the #{license} license" do
      verify_license_file(license)
    end

    context 'when modified' do
      should "detect the #{license} license" do
        verify_license_file(license, true) unless SKIP.include?(File.basename(license, '.txt'))
      end
    end

    context 'different line lengths' do
      should "detect the #{license} license" do
        verify_license_file(license, false, 50)
      end

      context 'when modified' do
        should "detect the #{license} license" do
          verify_license_file(license, true, 50) unless SKIP.include?(File.basename(license, '.txt'))
        end
      end
    end
  end
end
