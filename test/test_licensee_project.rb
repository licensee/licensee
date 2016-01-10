require 'helper'
require 'fileutils'

class TestLicenseeProject < Minitest::Test
  %w(git filesystem).each do |project_type|
    describe("#{project_type} repository project") do
      if project_type == 'git'
        def make_project(fixture_name)
          fixture = fixture_path fixture_name
          Licensee::GitProject.new(fixture)
        end
      else
        def make_project(fixture_name)
          dest = File.join('tmp', 'fixtures', fixture_name)
          FileUtils.mkdir_p File.dirname(dest)
          system 'git', 'clone', '-q', fixture_path(fixture_name), dest
          FileUtils.rm_r File.join(dest, '.git')

          Licensee::FSProject.new(dest)
        end

        def teardown
          FileUtils.rm_rf 'tmp/fixtures'
        end
      end

      should 'detect the license file' do
        project = make_project 'licenses.git'
        assert_instance_of Licensee::Project::LicenseFile, project.license_file
      end

      should 'detect the license' do
        project = make_project 'licenses.git'
        assert_equal 'mit', project.license.key
      end

      should 'detect an atypically cased license file' do
        project = make_project 'case-sensitive.git'
        assert_instance_of Licensee::Project::LicenseFile, project.license_file
      end

      should 'detect MIT-LICENSE licensed projects' do
        project = make_project 'named-license-file-prefix.git'
        assert_equal 'mit', project.license.key
      end

      should 'detect LICENSE-MIT licensed projects' do
        project = make_project 'named-license-file-suffix.git'
        assert_equal 'mit', project.license.key
      end

      should 'not error out on repos with folders names license' do
        project = make_project 'license-folder.git'
        assert_equal nil, project.license
      end

      should 'detect licence files' do
        project = make_project 'licence.git'
        assert_equal 'mit', project.license.key
      end

      should 'detect an unlicensed project' do
        project = make_project 'no-license.git'
        assert_equal nil, project.license
      end
    end
  end

  describe 'mit license with title removed' do
    should 'detect the MIT license' do
      verify_license_file fixture_path('mit-without-title/mit.txt')
    end

    should 'should detect the MIT license when rewrapped' do
      verify_license_file fixture_path('mit-without-title-rewrapped/mit.txt')
    end
  end

  describe 'packages' do
    should 'detect a package file' do
      project = Licensee::GitProject.new(fixture_path('npm.git'), detect_packages: true)
      assert_equal 'package.json', project.package_file.filename
      assert_equal 'mit', project.license.key
    end

    should 'skip readme if no license content' do
      project = Licensee::FSProject.new(fixture_path('bower-with-readme'),
                                        detect_packages: true, detect_readme: true)
      assert_equal 'mit', project.license.key
    end
  end
end
