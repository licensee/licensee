require 'helper'

class TestLicensee < Minitest::Test
  should "know load licenses" do
    assert_equal Array, Licensee.licenses.class
    assert_equal 16, Licensee.licenses.size
    assert_equal Licensee::License, Licensee.licenses.first.class
  end
end
