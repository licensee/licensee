# encoding=utf-8
require 'helper'

class TestLicenseeCopyrightMatchers < Minitest::Test
  should "match the license" do
    text = "Copyright 2015 Ben Balter"
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal "no-license", Licensee::Matchers::Copyright.new(file).match.key
  end

  should "know the match confidence" do
    text = "Copyright 2015 Ben Balter"
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal 100, Licensee::Matchers::Copyright.new(file).confidence
  end

  should "match Copyright (C) copyright notices" do
    text = "Copyright (C) 2015 Ben Balter"
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal "no-license", Licensee::Matchers::Copyright.new(file).match.key
  end

  should "match Copyright © copyright notices" do
    text = "copyright © 2015 Ben Balter"
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal "no-license", Licensee::Matchers::Copyright.new(file).match.key
  end

  should "not false positive" do
    text = File.open(Licensee::License.find("mit").path).read.split("---").last
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal nil, Licensee::Matchers::Copyright.new(file).match
  end

  should "handle UTF-8 encoded copyright notices" do
    text = "Copyright (c) 2010-2014 Simon Hürlimann"
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal "no-license", Licensee::Matchers::Copyright.new(file).match.key
  end

  should "handle ASCII-8BIT encoded copyright notices" do
    text = "Copyright \xC2\xA92015 Ben Balter`".force_encoding("ASCII-8BIT")
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal "no-license", Licensee::Matchers::Copyright.new(file).match.key
  end

  should "match comma, separated dates" do
    text = "Copyright (c) 2003, 2004 Ben Balter"
    file = Licensee::Project::LicenseFile.new(text)
    assert_equal "no-license", Licensee::Matchers::Copyright.new(file).match.key
  end
 end
