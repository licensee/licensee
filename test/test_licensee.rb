require 'helper'

class TestLicensee < Minitest::Test

  should "know license names" do
    assert_equal Array, Licensee.license_names.class
    assert_equal 16, Licensee.license_names.size
  end

  should "load the licenses" do
    assert_equal Array, Licensee.licenses.class
    assert_equal 16, Licensee.licenses.size
    assert_equal Licensee::License, Licensee.licenses.first.class
  end
  
end
