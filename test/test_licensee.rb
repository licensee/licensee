require 'helper'

class TestLicensee < Minitest::Test
  should 'know the licenses' do
    assert_equal Array, Licensee.licenses.class
    assert_equal 7, Licensee.licenses.size
    assert_equal 29, Licensee.licenses(hidden: true).size
    assert_equal Licensee::License, Licensee.licenses.first.class
  end

  should "detect a project's license" do
    assert_equal 'mit', Licensee.license(fixture_path('licenses.git')).key
  end

  should "detect a file's license" do
    file = fixture_path('apache-2.0/LICENSE')
    assert_equal 'apache-2.0', Licensee.license(file).key
  end

  should 'init a project' do
    project = Licensee.project(fixture_path('licenses.git'))
    assert_equal Licensee::GitProject, project.class
  end

  context 'confidence threshold' do
    should 'return the confidence threshold' do
      assert_equal 95, Licensee.confidence_threshold
    end

    should 'let the user override the confidence threshold' do
      Licensee.confidence_threshold = 50
      assert_equal 50, Licensee.confidence_threshold
      Licensee.confidence_threshold = 95
    end

    should 'return the inverse of the confidence threshold' do
      assert_equal 0.05, Licensee.inverse_confidence_threshold
    end
  end
end
