require 'helper'

class TestLicenseeNpmBowerMatcher < Minitest::Test

  def setup
    Licensee.package_manager_files = true
  end

  def teardown
    Licensee.package_manager_files = false
  end

  should "detect NPM files" do
    project = Licensee::Project.new fixture_path "npm"
    matcher = Licensee::NpmBowerMatcher.new(project.package_file)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end

  should "detect Bower files" do
    project = Licensee::Project.new fixture_path "bower"
    matcher = Licensee::NpmBowerMatcher.new(project.package_file)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end

  should "not err on non-spdx licenses" do
    project = Licensee::Project.new fixture_path "npm-non-spdx"
    matcher = Licensee::NpmBowerMatcher.new(project.package_file)
    assert_equal "mit-1.0", matcher.send(:license_property)
    assert_equal nil, matcher.match
  end
end
