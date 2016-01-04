require 'helper'

class TestLicenseeGemspecMatchers < Minitest::Test
  should "detect its own license" do
    root = File.expand_path "../", File.dirname(__FILE__)
    project = if rugged?
      Licensee::GitProject.new(root, detect_packages: true)
    else
      Licensee::FSProject.new(root, detect_packages: true)
    end
    matcher = Licensee::Matchers::Gemspec.new(project.package_file)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end
end
