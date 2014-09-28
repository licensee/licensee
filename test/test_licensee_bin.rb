require 'helper'

class TestLicenseeBin < Minitest::Test
  should "work via commandline" do
    root = File.expand_path "..", File.dirname(__FILE__)
    Dir.chdir root
    stdout,stderr,status = Open3.capture3("#{root}/bin/licensee")
    assert stdout.include?("License: MIT"), "expected #{stdout} to include `License: MIT`"
    assert stdout.include?("Match: 98.45%"), "expected #{stdout} to include `Match: 98.42%`"
  end
end
