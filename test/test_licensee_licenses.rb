require 'helper'

class TestLicenseeLicenses < Minitest::Test

  should "know license names" do
    assert_equal Array, Licensee::Licenses.names.class
    assert_equal 16, Licensee::Licenses.names.size
  end

  should "load the licenses" do
    assert_equal Array, Licensee::Licenses.list.class
    assert_equal 16, Licensee::Licenses.list.size
    assert_equal Licensee::License, Licensee::Licenses.list.first.class
  end

  should "find a license" do
    assert_equal "MIT", Licensee::Licenses.find("MIT").name
  end

end
