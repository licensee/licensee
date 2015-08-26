require 'helper'

class TestLicensee < Minitest::Test
  should "know the licenses" do
    assert_equal Array, Licensee.licenses.class
    assert_equal 19, Licensee.licenses.size
    assert_equal Licensee::License, Licensee.licenses.first.class
  end

  should "detect a project's license" do
    assert_equal "mit", Licensee.license(fixture_path("licenses.git")).key
  end

  should "diff a license" do
    Licensee.diff(fixture_path("licenses.git"))
  end

  context "confidence threshold" do
    should "return the confidence threshold" do
      assert_equal 90, Licensee.confidence_threshold
    end

    should "let the user override the confidence threshold" do
      Licensee.confidence_threshold = 50
      assert_equal 50, Licensee.confidence_threshold
      Licensee.confidence_threshold = 90
    end
  end

  context "npm-bower matcher" do
    should "be disabled by default" do
      refute Licensee.matchers.include? Licensee::NpmBowerMatcher
    end

    should "be enable-able" do
      Licensee.package_manager_files = true
      assert Licensee.matchers.include? Licensee::NpmBowerMatcher
      Licensee.package_manager_files = false
    end
  end
end
