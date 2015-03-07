require 'helper'

class TestLicenseeCopyrightMatcher < Minitest::Test

  def setup
    text = "Copyright 2015 Ben Balter"
    blob = FakeBlob.new(text)
    @file = Licensee::LicenseFile.new(blob)
  end

  should "match the license" do
    assert_equal "no-license", Licensee::CopyrightMatcher.match(@file).key
  end

  should "know the match confidence" do
    assert_equal 100, Licensee::CopyrightMatcher.new(@file).confidence
  end

  should "match (C) copyright notices" do
    text = "(C) 2015 Ben Balter"
    blob = FakeBlob.new(text)
    file = Licensee::LicenseFile.new(blob)
    assert_equal "no-license", Licensee::CopyrightMatcher.match(file).key
  end

  should "match © copyright notices" do
    text = "© 2015 Ben Balter"
    blob = FakeBlob.new(text)
    file = Licensee::LicenseFile.new(blob)
    assert_equal "no-license", Licensee::CopyrightMatcher.match(file).key
  end

  should "not false positive" do
    text = File.open(Licensee::Licenses.find("mit").path).read.split("---").last
    blob = FakeBlob.new(text)
    file = Licensee::LicenseFile.new(blob)
    assert_equal nil, Licensee::CopyrightMatcher.match(file)
  end
end
