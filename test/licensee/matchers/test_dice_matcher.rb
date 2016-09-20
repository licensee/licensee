require 'helper'

class TestLicenseeDiceMatchers < Minitest::Test
  def setup
    text = license_from_path(Licensee::License.find('mit').path)
    @mit = Licensee::Project::LicenseFile.new(text)

    text = license_from_path(Licensee::License.find('gpl-2.0').path)
    @gpl = Licensee::Project::LicenseFile.new(text)
  end

  def concat_licenses(*args)
    args.map do |license|
      license_from_path(Licensee::License.find(license).path)
    end.join("\n")
  end

  should 'match the license' do
    assert_equal 'mit', Licensee::Matchers::Dice.new(@mit).match.key
  end

  should 'know the match confidence' do
    matcher = Licensee::Matchers::Dice.new(@mit)
    assert matcher.confidence > 95, "#{matcher.confidence} < 95"
  end

  should 'know when two licenses have be concatenated' do
    text = concat_licenses('mit', 'gpl-2.0')
    license = Licensee::Project::LicenseFile.new(text)
    matcher = Licensee::Matchers::Dice.new(license)
    if matcher.match
      msg = "Expected no-license, got #{matcher.match.key}"
      msg << " (#{matcher.match.similarity(license).round(2)}% similar)"
    end
    refute matcher.match, msg
  end

  should 'build the list of licenses by similarity' do
    matcher = Licensee::Matchers::Dice.new(@gpl)

    match = matcher.licenses_by_similiarity.first
    assert_equal Licensee::License, match[0].class
    assert_equal 'gpl-2.0', match[0].key
    assert_equal 100.0, match[1]

    match = matcher.licenses_by_similiarity[1]
    assert_equal 'lppl-1.3c', match[0].key
    assert_equal 49.52, match[1].round(2)
  end

  should 'build the list of matches' do
    matcher = Licensee::Matchers::Dice.new(@gpl)

    assert_equal 1, matcher.matches.count
    match = matcher.matches.first
    assert_equal Licensee::License, match[0].class
    assert_equal 'gpl-2.0', match[0].key
    assert_equal 100.0, match[1]
  end
end
