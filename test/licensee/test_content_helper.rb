require 'helper'

class ContentHelperTestHelper
  include Licensee::ContentHelper
  attr_accessor :content

  DEFAULT_CONTENT = <<-EOS.freeze
Copyright 2016 Ben Balter

The made
up  license.
-----------
  EOS

  def initialize(content = nil)
    @content = content || DEFAULT_CONTENT
  end
end

class TestLicenseeContentHelper < Minitest::Test
  def setup
    @helper = ContentHelperTestHelper.new
  end

  context 'normalizing' do
    should 'strips copyright' do
      refute_match('Copyright', @helper.content_normalized)
      refute_match('Ben Balter', @helper.content_normalized)
    end

    should 'downcases' do
      refute_match('The', @helper.content_normalized)
      assert_match('the', @helper.content_normalized)
    end

    should 'strips HRs' do
      refute_match('---', @helper.content_normalized)
    end

    should 'squeeze whitespace' do
      refute_match('  ', @helper.content_normalized)
    end

    should 'strips whitespace' do
      refute_match(/\n/i, @helper.content_normalized)
    end

    should 'normalize the content' do
      assert_equal 'the made up license.', @helper.content_normalized
    end
  end

  should 'generate the hash' do
    assert_equal '3c59634b9fae4396a76a978f3f6aa718ed790a9a', @helper.hash
  end

  should 'calculate the length' do
    assert_equal 20, @helper.length
  end

  should 'know the max delta' do
    assert_equal 1, @helper.max_delta
  end

  should 'build the wordset' do
    assert_equal %w(the made up license).to_set, @helper.wordset
  end

  should 'calculate the length delta' do
    other = ContentHelperTestHelper.new 'asdf'
    assert_equal 16, @helper.length_delta(other)
  end

  should 'calculate the similarity' do
    other = ContentHelperTestHelper.new 'asdf'
    assert_equal 0, @helper.similarity(other)

    other = ContentHelperTestHelper.new 'Not really the made up license'
    assert_equal 80.0, @helper.similarity(other)
  end
end
