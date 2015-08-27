require 'helper'

class TestLicenseeGemspecMatcher < Minitest::Test
  def setup
    Licensee.package_manager_files = true
  end

  def teardown
    Licensee.package_manager_files = false
  end

  should "detect its own license" do
    root = File.expand_path "../", File.dirname(__FILE__)
    project = Licensee::Project.new(root)
    matcher = Licensee::GemspecMatcher.new(project.package_file)
    assert_equal "mit", matcher.send(:license_property)
    assert_equal "mit", matcher.match.key
  end
end
