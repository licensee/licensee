require 'helper'

class PackageMatcherTestHelper < Licensee::Matchers::Package
  attr_accessor :license_property, :file
end

class TestLicenseePackageMatcher < Minitest::Test
  def setup
    pkg = File.read fixture_path('npm/package.json')
    @file = Licensee::Project::PackageInfo.new(pkg)
    @matcher = PackageMatcherTestHelper.new(@file)
    @matcher.license_property = 'mit'
  end

  should 'store the file' do
    assert_equal @matcher.file, @file
  end

  should 'match' do
    assert @matcher.match
    assert_equal 'mit', @matcher.match.key
  end

  should 'return the confidence' do
    assert_equal 90, @matcher.confidence
  end
end
