require 'helper'

class TestLicenseeExactMatchers < Minitest::Test
  def setup
    path = Licensee::License.find('mit').path
    text = File.read(path, encoding: 'utf-8').split('---').last
    @mit = Licensee::Project::LicenseFile.new(text)
  end

  should 'match the license' do
    assert_equal 'mit', Licensee::Matchers::Exact.new(@mit).match.key
  end

  should 'know the match confidence' do
    assert_equal 100, Licensee::Matchers::Exact.new(@mit).confidence
  end
end
