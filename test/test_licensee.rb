require 'helper'

class TestLicensee < Minitest::Test
  should "know the licenses" do
    assert_equal Array, Licensee.licenses.class
    assert_equal 15, Licensee.licenses.size
    assert_equal 24, Licensee.licenses(:hidden => true).size
    assert_equal Licensee::License, Licensee.licenses.first.class
  end

  should "detect a project's license" do
    fixture = "licenses"
    fixture << ".git" if rugged?
    assert_equal "mit", Licensee.license(fixture_path(fixture)).key
  end

  should "init a project" do
    fixture = "licenses"
    if rugged?
      fixture << ".git"
      expected = Licensee::GitProject
    else
      expected = Licensee::FSProject
    end
    assert_equal expected, Licensee.project(fixture_path(fixture)).class
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
end
