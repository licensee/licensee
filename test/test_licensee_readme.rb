require 'helper'

class TestLicenseeReadme < Minitest::Test
  context "readme filename scoring" do
    EXPECTATIONS = {
      "readme"      => 1.0,
      "README"      => 1.0,
      "readme.md"   => 0.9,
      "README.md"   => 0.9,
      "readme.txt"  => 0.9,
      "LICENSE"     => 0.0
    }

    EXPECTATIONS.each do |filename, expected|
      should "score a readme named `#{filename}` as `#{expected}`" do
        assert_equal expected, Licensee::Project::Readme.name_score(filename)
      end
    end

  end

  context "readme content" do
    should "be blank if not license text" do
      content = Licensee::Project::Readme.license_content("There is no License in this README")
      assert_equal nil, content
    end

    should "get content after h1" do
      content = Licensee::Project::Readme.license_content("# License\n\nhello world")
      assert_equal "hello world", content
    end

    should "get content after h2" do
      content = Licensee::Project::Readme.license_content("## License\n\nhello world")
      assert_equal "hello world", content
    end

    should "be case-insensitive" do
      content = Licensee::Project::Readme.license_content("## LICENSE\n\nhello world")
      assert_equal "hello world", content
    end

    should "be british" do
      content = Licensee::Project::Readme.license_content("## Licence\n\nhello world")
      assert_equal "hello world", content
    end

    should "not include trailing content" do
      content = Licensee::Project::Readme.license_content("## License\n\nhello world\n\n# Contributing")
      assert_equal "hello world", content
    end
  end
end
