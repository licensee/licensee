require 'helper'

class TestLicenseeBin < Minitest::Test
  should 'work via commandline' do
    root = File.expand_path '..', File.dirname(__FILE__)
    Dir.chdir root
    stdout, stderr, status = Open3.capture3("#{root}/bin/licensee")

    msg = "expected #{stdout} to include `License: MIT`"
    assert stdout.include?('License: MIT'), msg

    msg = "expected #{stdout} to include `Matched file: LICENSE.md`"
    assert stdout.include?('License file: LICENSE.md'), msg

    assert_equal 0, status
    assert stderr.empty?
  end

  should 'work via commandline with file argument' do
    root = File.expand_path '..', File.dirname(__FILE__)
    Dir.chdir root
    stdout, stderr, status = Open3.capture3("#{root}/bin/licensee LICENSE.md")

    msg = "expected #{stdout} to include `License: MIT`"
    assert stdout.include?('License: MIT'), msg

    msg = "expected #{stdout} to include `Matched file: LICENSE.md`"
    assert stdout.include?('License file: LICENSE.md'), msg

    assert_equal 0, status
    assert stderr.empty?
  end
end
