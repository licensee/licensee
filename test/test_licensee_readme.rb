require 'helper'

class TestLicenseeReadme < Minitest::Test
  context 'readme filename scoring' do
    EXPECTATIONS = {
      'readme'     => 1.0,
      'README'     => 1.0,
      'readme.md'  => 0.9,
      'README.md'  => 0.9,
      'readme.txt' => 0.9,
      'LICENSE'    => 0.0
    }.freeze

    EXPECTATIONS.each do |filename, expected|
      should "score a readme named `#{filename}` as `#{expected}`" do
        assert_equal expected, Licensee::Project::Readme.name_score(filename)
      end
    end
  end

  context 'readme content' do
    should 'be blank if not license text' do
      assert_license_content nil, 'There is no License in this README'
    end

    should 'get content after h1' do
      assert_license_content 'hello world', "# License\n\nhello world"
    end

    should 'get content after h2' do
      assert_license_content 'hello world', "## License\n\nhello world"
    end

    should 'be case-insensitive' do
      assert_license_content 'hello world', "## LICENSE\n\nhello world"
    end

    should 'be british' do
      assert_license_content 'hello world', "## Licence\n\nhello world"
    end

    should 'not include trailing content' do
      readme = "## License\n\nhello world\n\n# Contributing"
      assert_license_content 'hello world', readme
    end
  end
end
