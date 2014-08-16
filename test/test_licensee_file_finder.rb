require 'helper'

class TestLicenseeFileFinder < Minitest::Test
  def setup
    path = File.expand_path "LICENSE", fixture_path("simple")
    @finder = Licensee::FileFinder.new path
  end

  should "read the file" do
    assert @finder.contents =~ /MIT/
  end
end
