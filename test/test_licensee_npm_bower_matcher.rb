require 'helper'

class TestLicenseeNpmBowerMatcher < Minitest::Test
  should "detect NPM files" do
    project = Licensee::Project.new(fixture_path("npm"), detect_packages: true)
    matcher = Licensee::Matcher::NpmBower.new(project.package_file)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end

  should "detect Bower files" do
    project = Licensee::Project.new(fixture_path("bower"), detect_packages: true)
    matcher = Licensee::Matcher::NpmBower.new(project.package_file)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end

  should "not err on non-spdx licenses" do
    project = Licensee::Project.new(fixture_path("npm-non-spdx"), detect_packages: true)
    matcher = Licensee::Matcher::NpmBower.new(project.package_file)
    assert_equal "mit-1.0", matcher.send(:license_property)
    assert_equal nil, matcher.match
  end
end
