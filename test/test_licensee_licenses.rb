require 'helper'

class TestLicenseeLicenses < Minitest::Test

  should "know license names" do
    assert_equal Array, Licensee::Licenses.send(:keys).class
    assert_equal 15, Licensee::Licenses.send(:keys).size
  end

  should "load the licenses" do
    assert_equal Array, Licensee::Licenses.list.class
    assert_equal 15, Licensee::Licenses.list.size
    assert_equal Licensee::License, Licensee::Licenses.list.first.class
  end

  should "find a license" do
    assert_equal "mit", Licensee::Licenses.find("mit").key
    assert_equal "mit", Licensee::Licenses.find("MIT").key
    assert_equal "mit", Licensee::Licenses["mit"].key
  end

  should "sort the licenses" do
    assert_equal "apache-2.0", Licensee::Licenses.sorted_list.first.key
    assert_equal "bsd-2-clause", Licensee::Licenses.sorted_list.last.key
  end
end
