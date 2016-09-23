require 'helper'

class TestLicenseeLicenseFile < Minitest::Test
  def setup
    @repo = Rugged::Repository.new(fixture_path('licenses.git'))
    ref   = 'bcb552d06d9cf1cd4c048a6d3bf716849c2216cc'
    blob, = Rugged::Blob.to_buffer(@repo, ref)
    @class = Licensee::Project::LicenseFile
    @file = @class.new(blob)
  end

  context 'content' do
    should 'parse the attribution' do
      assert_equal 'Copyright (c) 2014 Ben Balter', @file.attribution
    end

    should 'not choke on non-UTF-8 licenses' do
      text = "\x91License\x93".force_encoding('windows-1251')
      file = @class.new(text)
      assert_equal nil, file.attribution
    end

    should 'create the wordset' do
      assert_equal 93, @file.wordset.count
      assert_equal 'the', @file.wordset.first
    end

    should 'create the hash' do
      assert_equal 'fb278496ea4663dfcf41ed672eb7e56eb70de798', @file.hash
    end
  end

  context 'license filename scoring' do
    EXPECTATIONS = {
      'license'            => 1.0,
      'LICENCE'            => 1.0,
      'unLICENSE'          => 1.0,
      'unlicence'          => 1.0,
      'license.md'         => 0.9,
      'LICENSE.md'         => 0.9,
      'license.txt'        => 0.9,
      'COPYING'            => 0.8,
      'copyRIGHT'          => 0.8,
      'COPYRIGHT.txt'      => 0.7,
      'copying.txt'        => 0.7,
      'LICENSE.php'        => 0.6,
      'LICENCE.docs'       => 0.6,
      'copying.image'      => 0.5,
      'COPYRIGHT.go'       => 0.5,
      'LICENSE-MIT'        => 0.4,
      'MIT-LICENSE.txt'    => 0.4,
      'mit-license-foo.md' => 0.4,
      'COPYING-GPL'        => 0.3,
      'COPYRIGHT-BSD'      => 0.3,
      'README.txt'         => 0.0
    }.freeze

    EXPECTATIONS.each do |filename, expected|
      should "score a license named `#{filename}` as `#{expected}`" do
        score = @class.name_score(filename)
        assert_equal expected, score
      end
    end
  end

  context 'LGPL scoring' do
    {
      'COPYING.lesser' => 1,
      'copying.lesser' => 1,
      'license.lesser' => 0,
      'LICENSE.md'     => 0,
      'FOO.md'         => 0
    }.each do |filename, expected|
      should "score a license named `#{filename}` as `#{expected}`" do
        score = @class.lesser_gpl_score(filename)
        assert_equal expected, score
      end
    end
  end

  context 'preferred license regex' do
    %w(md markdown txt).each do |ext|
      should "match .#{ext}" do
        assert_match @class::PREFERRED_EXT_REGEX, ".#{ext}"
      end
    end

    should 'not match .md2' do
      refute_match @class::PREFERRED_EXT_REGEX, '.md2'
    end

    should 'not match .md/foo' do
      refute_match @class::PREFERRED_EXT_REGEX, '.md/foo'
    end
  end

  context 'any extension regex' do
    should 'match .foo' do
      assert_match @class::ANY_EXT_REGEX, '.foo'
    end

    should 'not match .md/foo' do
      refute_match @class::ANY_EXT_REGEX, '.md/foo'
    end
  end

  context 'license regex' do
    %w(LICENSE licence unlicense LICENSE-MIT MIT-LICENSE).each do |license|
      should "match #{license}" do
        assert_match @class::LICENSE_REGEX, license
      end
    end
  end

  context 'copying regex' do
    %w(COPYING copyright).each do |copying|
      should "match #{copying}" do
        assert_match @class::COPYING_REGEX, copying
      end
    end
  end
end
