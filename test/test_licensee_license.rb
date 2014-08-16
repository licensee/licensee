require 'helper'

class TestLicenseeLicense < Minitest::Test

  def setup
    @license = Licensee::License.new "MIT"
  end

  should "read the license body" do
    assert @license.body
    assert @license.length > 0
    assert @license.body =~ /MIT/
  end

  should "read the license meta" do
    assert_equal "MIT License", @license.meta["title"]
  end

end
