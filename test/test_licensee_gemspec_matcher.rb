require 'helper'

class TestLicenseeGemspecMatchers < Minitest::Test
  should "detect its own license" do
    root = File.expand_path "../", File.dirname(__FILE__)
    project = Licensee::GitProject.new(root, detect_packages: true)
    matcher = Licensee::Matchers::Gemspec.new(project.package_file)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end
end
