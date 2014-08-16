require 'helper'

class TestLicenseeReadme < Minitest::Test

  def setup
    @readme = Licensee::Readme.find fixture_path("simple")
  end

  should "match the license" do
    assert_equal "MIT", @readme.match.name
  end

end
