require 'helper'

class TestLicenseePackageInfo < Minitest::Test
  context 'license filename scoring' do
    EXPECTATIONS = {
      'licensee.gemspec' => 1.0,
      'package.json'     => 1.0,
      'bower.json'       => 0.75,
      'README.md'        => 0.0
    }.freeze

    EXPECTATIONS.each do |filename, expected|
      should "score a license named `#{filename}` as `#{expected}`" do
        score = Licensee::Project::PackageInfo.name_score(filename)
        assert_equal expected, score
      end
    end
  end
end
