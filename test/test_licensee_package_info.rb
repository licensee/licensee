require 'helper'

class TestLicenseePackageInfo < Minitest::Test
  context "license filename scoring" do
    EXPECTATIONS = {
      "licensee.gemspec" => 1.0,
      "package.json"     => 1.0,
      "bower.json"       => 0.75,
      "README.md"        => 0.0
    }

    EXPECTATIONS.each do |filename, expected|
      should "score a license named `#{filename}` as `#{expected}`" do
        assert_equal expected, Licensee::Project::PackageInfo.name_score(filename)
      end
    end
  end
end
