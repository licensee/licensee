require 'helper'

class TestLicenseeLicense < Minitest::Test

  def setup
    @license = Licensee::License.new "MIT"
  end

  should "read the license body" do
    assert @license.body
    assert @license.text =~ /MIT/
  end

  should "read the license meta" do
    assert_equal "MIT License", @license.meta["title"]
  end

  should "know the license path" do
    assert_equal File.expand_path("./vendor/choosealicense.com/_licenses/mit.txt"), @license.path
  end

  should "know the license name" do
    assert_equal "MIT License", @license.name
  end

  should "know the license ID" do
    assert_equal "mit", @license.key
  end

  should "know if the license is featured" do
    assert @license.featured?
    assert_equal TrueClass, @license.featured?.class
    refute Licensee::License.new("cc0-1.0").featured?
    assert_equal FalseClass, Licensee::License.new("cc0-1.0").featured?.class
  end

  should "parse the license parts" do
    assert_equal 3, @license.send(:parts).size
  end

  should "build the license URL" do
    assert_equal "http://choosealicense.com/licenses/mit/", @license.url
  end

  should "return all licenses" do
    assert_equal Array, Licensee::License.all.class
    assert Licensee::License.all.size > 3
  end

  should "strip leading newlines from the license" do
    assert_equal "T", @license.body[0]
  end

  should "fail loudly for invalid licenses" do
    assert_raises(Licensee::InvalidLicense) { Licensee::License.new("foo").name }
  end
end
