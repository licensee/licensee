require 'helper'

class TestLicenseeDiceMatchers < Minitest::Test
  def setup
    text = license_from_path(Licensee::License.find('mit').path)
    @mit = Licensee::Project::LicenseFile.new(text)
  end

  def concat_licenses(*args)
    args.map { |l| license_from_path(Licensee::License.find(l).path) }.join("\n")
  end

  should 'match the license' do
    assert_equal 'mit', Licensee::Matchers::Dice.new(@mit).match.key
  end

  should 'know the match confidence' do
    matcher = Licensee::Matchers::Dice.new(@mit)
    assert matcher.confidence > 95, "#{matcher.confidence} < 95"
  end

  should 'calculate max delta' do
    assert_equal 83.7, Licensee::Matchers::Dice.new(@mit).max_delta
  end

  should "know when two licenses have be concatenated" do
    text= concat_licenses("mit", "gpl-2.0")
    license = Licensee::Project::LicenseFile.new(text)
    matcher = Licensee::Matchers::Dice.new(license)
    refute_equal "gpl-2.0", matcher.match.key
  end
end
