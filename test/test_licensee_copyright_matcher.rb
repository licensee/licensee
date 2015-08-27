# encoding=utf-8
require 'helper'

class TestLicenseeCopyrightMatcher < Minitest::Test

  def setup
    text = "Copyright 2015 Ben Balter"
    blob = FakeBlob.new(text)
    @file = Licensee::ProjectFile.new(blob, "LICENSE")
  end

  should "match the license" do
    assert_equal "no-license", Licensee::CopyrightMatcher.match(@file).key
  end

  should "know the match confidence" do
    assert_equal 100, Licensee::CopyrightMatcher.new(@file).confidence
  end

  should "match Copyright (C) copyright notices" do
    text = "Copyright (C) 2015 Ben Balter"
    blob = FakeBlob.new(text)
    file = Licensee::ProjectFile.new(blob, "LICENSE")
    assert_equal "no-license", Licensee::CopyrightMatcher.match(file).key
  end

  should "match Copyright © copyright notices" do
    text = "copyright © 2015 Ben Balter"
    blob = FakeBlob.new(text)
    file = Licensee::ProjectFile.new(blob, "LICENSE")
    assert_equal "no-license", Licensee::CopyrightMatcher.match(file).key
  end

  should "not false positive" do
    text = File.open(Licensee::Licenses.find("mit").path).read.split("---").last
    blob = FakeBlob.new(text)
    file = Licensee::ProjectFile.new(blob, "LICENSE")
    assert_equal nil, Licensee::CopyrightMatcher.match(file)
  end

  should "handle UTF-8 encoded copyright notices" do
    text = "Copyright (c) 2010-2014 Simon Hürlimann"
    blob = FakeBlob.new(text)
    file = Licensee::ProjectFile.new(blob, "LICENSE")
    assert_equal "no-license", Licensee::CopyrightMatcher.match(file).key
  end

  should "handle ASCII-8BIT encoded copyright notices" do
    text = "Copyright \xC2\xA92015 Ben Balter`".force_encoding("ASCII-8BIT")
    blob = FakeBlob.new(text)
    file = Licensee::ProjectFile.new(blob, "LICENSE")
    assert_equal "no-license", Licensee::CopyrightMatcher.match(file).key
  end
 end
