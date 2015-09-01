require 'helper'

class TestHelper
  include Licensee::ContentHelper
end

class TestLicenseeContentHelper < Minitest::Test

  def setup
    @helper = TestHelper.new
  end

  def normalize(content)
    @helper.normalize_content(content)
  end

  should "downcase content" do
    assert_equal "foo", normalize("Foo")
  end

  should "strip leading whitespace" do
    assert_equal "foo", normalize("\n Foo")
  end

  should "strip trailing whitespace" do
    assert_equal "foo", normalize("Foo \n ")
  end

  should "strip double spaces" do
    assert_equal "foo bar", normalize("Foo  bar")
  end

  should "strip copyrights" do
    assert_equal "foo", normalize("Copyright (c) 2015 Ben Balter\nFoo")
  end
end
