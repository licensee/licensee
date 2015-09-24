require 'helper'

class TestLicenseeNpmBowerMatchers < Minitest::Test
  should "detect NPM files" do
    pkg = File.read fixture_path("npm/package.json")
    pkgfile = Licensee::Project::PackageInfo.new(pkg)
    matcher = Licensee::Matchers::NpmBower.new(pkgfile)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end

  should "detect Bower files" do
    pkg = File.read fixture_path("bower/bower.json")
    pkgfile = Licensee::Project::PackageInfo.new(pkg)
    matcher = Licensee::Matchers::NpmBower.new(pkgfile)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end

  should "not err on non-spdx licenses" do
    pkg = File.read fixture_path("npm-non-spdx/package.json")
    pkgfile = Licensee::Project::PackageInfo.new(pkg)
    matcher = Licensee::Matchers::NpmBower.new(pkgfile)
    assert_equal "mit-1.0", matcher.send(:license_property)
    assert_equal nil, matcher.match
  end
end
