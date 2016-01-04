require 'helper'

class TestLicenseeProjectFile < Minitest::Test

  def setup
    @file = licenses_file
    @gpl = Licensee::License.find "GPL-3.0"
    @mit = Licensee::License.find "MIT"
  end

  should "read the file" do
    assert @file.content =~ /MIT/
  end

  should "match the license" do
    assert_equal "mit", @file.license.key
  end

  should "calculate confidence" do
    assert_equal 100, @file.confidence
  end
end
