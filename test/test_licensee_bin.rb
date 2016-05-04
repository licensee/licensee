require 'helper'

class TestLicenseeBin < Minitest::Test
  should 'work via commandline' do
    root = File.expand_path '..', File.dirname(__FILE__)
    stdout, stderr, status = Dir.chdir root do
      args = [windows? && 'ruby', 'bin/licensee'].compact
      Open3.capture3(*args)
    end

    msg = "expected #{stdout} to include `License: MIT`"
    assert stdout.include?('License: MIT'), msg

    msg = "expected #{stdout} to include `Matched file: LICENSE.md`"
    assert stdout.include?('License file: LICENSE.md'), msg

    assert_equal 0, status
    assert stderr.empty?
  end

  should 'work via commandline with file argument' do
    root = File.expand_path '..', File.dirname(__FILE__)
    stdout, stderr, status = Dir.chdir root do
      args = [windows? && 'ruby', 'bin/licensee', 'LICENSE.md'].compact
      Open3.capture3(*args)
    end

    msg = "expected #{stdout} to include `License: MIT`"
    assert stdout.include?('License: MIT'), msg

    msg = "expected #{stdout} to include `Matched file: LICENSE.md`"
    assert stdout.include?('License file: LICENSE.md'), msg

    assert_equal 0, status
    assert stderr.empty?
  end
end
