require 'helper'

class ContentHelperTestHelper
  include Licensee::ContentHelper
  attr_accessor :content

  DEFAULT_CONTENT = <<-EOS.freeze
Copyright 2016 Ben Balter

The made up license.
  EOS

  def initialize(content = nil)
    @content = content || DEFAULT_CONTENT
  end
end

class TestLicenseeContentHelper < Minitest::Test
  def setup
    @helper = ContentHelperTestHelper.new
  end

  should 'normalize the content' do
    assert_equal 'the made up license.', @helper.content_normalized
  end

  should 'generate the hash' do
    assert_equal '3c59634b9fae4396a76a978f3f6aa718ed790a9a', @helper.hash
  end

  should 'calculate the length' do
    assert_equal 20, @helper.length
  end

  should 'build the wordset' do
    assert_equal %w(the made up license).to_set, @helper.wordset
  end
end
