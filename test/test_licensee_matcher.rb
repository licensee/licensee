require 'helper'

class TestLicenseeMatcher < Minitest::Test
  should "match the license without raising an error" do
    assert_nil Licensee::Matcher.match(nil)
  end
end
