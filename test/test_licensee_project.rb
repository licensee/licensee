require 'helper'

class TestLicenseeProject < Minitest::Test

  def setup
    @project = Licensee::Project.new fixture_path("licenses.git")
  end

  should "detect the license file" do
    assert_equal Licensee::LicenseFile, @project.license_file.class
  end

  should "detect the license" do
    assert_equal "mit", @project.license.key
  end

  should "know the last commit" do
    commit = @project.send(:commit)
    assert_equal Rugged::Commit, commit.class
    assert_equal "b02cbad9d254c41d16d56ed9d6d2cf07c1d837fd", commit.oid
  end

  should "retrieve the tree" do
    tree = @project.send(:tree)
    assert_equal 1, tree.count
    assert_equal "bcb552d06d9cf1cd4c048a6d3bf716849c2216cc", tree.first[:oid]
  end

  should "return the license blob" do
    assert_equal "LICENSE", @project.send(:license_blob)[:name]
  end

  should "detect an atypically cased license file" do
    project = Licensee::Project.new fixture_path("case-sensitive.git")
    assert_equal Licensee::LicenseFile, project.license_file.class
  end

  should "detect MIT-LICENSE licensed projects" do
    project = Licensee::Project.new fixture_path("named-license-file-prefix.git")
    assert_equal "mit", project.license.key
  end

  should "detect LICENSE-MIT licensed projects" do
    project = Licensee::Project.new fixture_path("named-license-file-suffix.git")
    assert_equal "mit", project.license.key
  end

  should "not error out on repos with folders names license" do
    project = Licensee::Project.new fixture_path("license-folder.git")
    assert_equal nil, project.license
  end

  should "detect licence files" do
    project = Licensee::Project.new fixture_path("licence.git")
    assert_equal "mit", project.license.key
  end
end
