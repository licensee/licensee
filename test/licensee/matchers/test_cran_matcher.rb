require 'helper'

class TestLicenseeCranMatchers < Minitest::Test
  should 'detect CRAN DESCRPITION files' do
    pkg = File.read fixture_path('cran/DESCRIPTION')
    pkgfile = Licensee::Project::PackageInfo.new(pkg)
    matcher = Licensee::Matchers::Cran.new(pkgfile)
    assert_equal 'mit', matcher.send(:license_property)
    assert_equal 'mit', matcher.match.key
  end
end
