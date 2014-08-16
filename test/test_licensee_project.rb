require 'helper'

class TestLicenseeProject < Minitest::Test

  def setup
    @project = Licensee::Project.new fixture_path("simple")
  end

  should "detect the license file" do
    assert_equal "LICENSE", @project.license_file
  end

  should "provide path to license file" do
    expected = File.expand_path "LICENSE", fixture_path("simple")
    assert_equal expected, @project.license_file_path
  end

  should "read the license file" do
    assert @project.license_contents =~ /MIT/
  end

  should "calculate the license length delta" do
    assert_equal 1073, @project.length_delta( "asdf" )
  end

  should "sort licenses by length delta" do
    assert_equal "MIT", @project.licenses_sorted.first.name
    assert_equal "GPL-3.0", @project.licenses_sorted.last.name
  end

  should "build an array of matched licenses" do
    assert @project.matches.first.match > ".9".to_f
    assert_equal "MIT", @project.matches.first.name
    assert_equal "no-license", @project.matches.last.name
    assert @project.matches.last.match > "0".to_f
  end

  should "detect the license" do
    assert_equal "MIT", @project.license.name
    assert @project.license.match > ".98".to_f
  end
end
