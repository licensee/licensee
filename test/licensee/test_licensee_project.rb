require 'helper'
require 'fileutils'

class TestLicenseeProject < Minitest::Test
  %w(git filesystem).each do |project_type|
    describe("#{project_type} repository project") do
      if project_type == 'git'
        def make_project(fixture_name)
          fixture = fixture_path fixture_name
          @project = Licensee::GitProject.new(fixture)
        end

        def teardown
          @project.close
        end
      else
        def make_project(fixture_name)
          base_name = File.basename(fixture_name, '.git')
          temp_name = Dir::Tmpname.make_tmpname(base_name, nil)
          @dest = File.join('tmp', 'fixtures', temp_name)
          FileUtils.rm_r @dest if File.directory? @dest
          Rugged::Repository.clone_at(fixture_path(fixture_name), @dest).close

          Licensee::FSProject.new(@dest)
        end

        def teardown
          FileUtils.rm_r @dest if File.directory? @dest

          # Also remove the parent directories in case they are empty.
          FileUtils.rmdir 'tmp/fixtures'
          FileUtils.rmdir 'tmp'
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

  describe 'licenses with title removed or altered' do
    should 'detect the MIT license without title' do
      verify_license_file fixture_path('mit-without-title/mit.txt')
    end

    should 'should detect the MIT license when rewrapped' do
      verify_license_file fixture_path('mit-without-title-rewrapped/mit.txt')
    end

    should 'detect the MIT license with redundant title' do
      verify_license_file fixture_path('mit-with-redundant-title/mit.txt')
    end

    should 'detect the BSD 2-clause license without title' do
      verify_license_file fixture_path(
        'bsd-2-clause-without-title/bsd-2-clause.txt'
      )
    end

    should 'detect the BSD 3-Clause license without title' do
      verify_license_file fixture_path(
        'bsd-3-clause-without-title/bsd-3-clause.txt'
      )
    end

    should 'detect the ISC license without title' do
      verify_license_file fixture_path('isc-without-title/isc.txt')
    end
  end

  describe 'packages' do
    should 'detect a package file' do
      path = fixture_path('npm.git')
      options = { detect_packages: true }
      project = Licensee::GitProject.new(path, options)
      assert_equal 'package.json', project.package_file.filename
      assert_equal 'mit', project.license.key
    end

    should 'skip readme if no license content' do
      path = fixture_path('bower-with-readme')
      options = { detect_packages: true, detect_readme: true }
      project = Licensee::FSProject.new(path, options)
      assert_equal 'mit', project.license.key
    end
  end
end
