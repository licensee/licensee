require 'helper'

class TestLicensee < Minitest::Test
  should "know the licenses" do
    assert_equal Array, Licensee.licenses.class
    assert_equal 16, Licensee.licenses.size
    assert_equal Licensee::License, Licensee.licenses.first.class
  end

  should "detect a project's license" do
    assert_equal "mit", Licensee.license(fixture_path("licenses.git")).key
  end

  should "diff a license" do
    Licensee.diff(fixture_path("licenses.git"))
  end
end
