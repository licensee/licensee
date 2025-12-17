# frozen_string_literal: true

module Integration
end

RSpec.describe Integration do
  [
    Licensee::Projects::FSProject,
    Licensee::Projects::GitProject
  ].each do |project_type|
    context "with a #{project_type} project" do
      subject(:project) { project_type.new(project_path, **arguments) }

      let(:filename) { 'LICENSE' }
      let(:license) { Licensee::License.find('mit') }
      let(:other_license) { Licensee::License.find('other') }
      let(:content) { license.content }
      let(:license_path) { File.expand_path(filename, project_path) }
      let(:arguments) { {} }
      let(:fixture) { 'mit' }
      let(:project_path) { fixture_path(fixture) }
      let(:initialize_git_repo) { project_type == Licensee::Projects::GitProject }
      let(:git_path) { File.expand_path('.git', project_path) }

      before { git_init(project_path) if initialize_git_repo }
      after { FileUtils.rm_rf(git_path) if initialize_git_repo }

      context 'with a folder named license' do
        let(:fixture) { 'license-folder' }

        it "doesn't match" do
          expect(project.license).to be_nil
        end
      end

      context 'with no license files' do
        let(:project_path) { Dir.mktmpdir }
        let(:file_path) { File.expand_path('foo.md', project_path) }

        before { File.write(file_path, 'bar') }
        after { FileUtils.rm_rf(project_path) }

        it 'returns nil' do
          expect(project.license).to be_nil
          expect(project.license_files).to be_empty

          expect(project.matched_file).to be_nil
          expect(project.matched_files).to be_empty
        end
      end

      context 'with LICENSE.lesser' do
        let(:license) { Licensee::License.find('lgpl-3.0') }
        let(:fixture) { 'lgpl' }

        it 'matches to LGPL' do
          expect(project.license).to eql(license)
          expect(project.license_file.path).to eql('COPYING.lesser')
        end
      end

      context 'with multiple license files' do
        let(:fixture) { 'multiple-license-files' }

        it 'matches other' do
          expect(project.license).to eql(other_license)
        end
      end

      context 'with multiple all rights reserved lines' do
        let(:license) { Licensee::License.find('bsd-3-clause') }
        let(:fixture) { 'multiple-arrs' }

        it 'matches other' do
          expect(project.license).to eql(license)
        end
      end

      context 'with CC-BY-NC-SA' do
        let(:fixture) { 'cc-by-nc-sa' }

        it 'matches other' do
          expect(project.license).to eql(other_license)
        end
      end

      context 'with CC-BY-ND' do
        let(:fixture) { 'cc-by-nd' }

        it 'matches other' do
          expect(project.license).to eql(other_license)
        end
      end

      context 'with WRK Modified Apache 2.0.1' do
        let(:fixture) { 'wrk-modified-apache' }

        it 'matches other' do
          expect(project.license).to eql(other_license)
        end
      end

      context 'with Pixar Modified Apache 2.0' do
        let(:fixture) { 'pixar-modified-apache' }

        it 'matches other' do
          expect(project.license).to eql(other_license)
        end
      end

      context 'with FCPL Modified MPL' do
        let(:fixture) { 'fcpl-modified-mpl' }

        it 'matches other' do
          expect(project.license).to eql(other_license)
        end
      end

      context 'MPL with HRs removed' do
        let(:license) { Licensee::License.find('mpl-2.0') }
        let(:fixture) { 'mpl-without-hrs' }

        it 'matches to MPL' do
          expect(project.license).to eql(license)
        end
      end

      context 'GPL3 with instructions removed' do
        let(:license) { Licensee::License.find('gpl-3.0') }
        let(:fixture) { 'gpl3-without-instructions' }

        it 'matches to GPL3' do
          expect(project.license).to eql(license)
        end
      end

      context 'DESCRIPTION file with a LICENSE file' do
        let(:fixture) { 'description-license' }
        let(:arguments) { { detect_packages: true } }

        it 'matches other' do
          expect(project.license).to eql(other_license)
          expect(project.package_file.path).to eql('DESCRIPTION')
        end
      end

      context 'A license with CRLF line-endings' do
        let(:license) { Licensee::License.find('gpl-3.0') }
        let(:fixture) { 'crlf-license' }

        it 'matches' do
          expect(project.license).to eql(license)
        end
      end

      context 'A BSD license with CRLF line-endings' do
        let(:license) { Licensee::License.find('bsd-3-clause') }
        let(:fixture) { 'crlf-bsd' }

        it 'matches' do
          expect(project.license).to eql(license)
        end
      end

      context 'BSD + PATENTS' do
        let(:license) { Licensee::License.find('other') }
        let(:fixture) { 'bsd-plus-patents' }

        it 'returns other' do
          expect(project.license).to eql(license)
        end
      end

      context 'BSL' do
        let(:license) { Licensee::License.find('bsl-1.0') }
        let(:fixture) { 'bsl' }

        it 'returns bsl-1.0' do
          expect(project.license).to eql(license)
        end
      end

      context 'CC0 as published by CC' do
        let(:license) { Licensee::License.find('cc0-1.0') }
        let(:fixture) { 'cc0-cc' }

        it 'returns cc0-1.0' do
          expect(project.license).to eql(license)
        end
      end

      context 'CC0 as published on choosealicense.com 2013-2019' do
        let(:license) { Licensee::License.find('cc0-1.0') }
        let(:fixture) { 'cc0-cal2013' }

        it 'returns cc0-1.0' do
          expect(project.license).to eql(license)
        end
      end

      context 'EUPL as published on choosealicense.com 2017-2019' do
        let(:license) { Licensee::License.find('eupl-1.2') }
        let(:fixture) { 'eupl-cal2017' }

        it 'returns eupl-1.2' do
          expect(project.license).to eql(license)
        end
      end

      context 'Unlicense without optional line' do
        let(:license) { Licensee::License.find('unlicense') }
        let(:fixture) { 'unlicense-noinfo' }

        it 'returns unlicense' do
          expect(project.license).to eql(license)
        end
      end

      context 'MIT w/optional phrase' do
        let(:license) { Licensee::License.find('mit') }
        let(:fixture) { 'mit-optional' }

        it 'returns mit' do
          expect(project.license).to eql(license)
        end
      end

      context 'license + README reference' do
        let(:license) { Licensee::License.find('mit') }
        let(:fixture) { 'license-with-readme-reference' }
        let(:arguments) { { detect_readme: true } }

        it 'determines the project is MIT' do
          expect(project.license).to eql(license)
        end
      end

      context 'apache license + README notice' do
        let(:license) { Licensee::License.find('apache-2.0') }
        let(:fixture) { 'apache-with-readme-notice' }
        let(:arguments) { { detect_readme: true } }

        it 'determines the project is Apache-2.0' do
          expect(project.license).to eql(license)
        end
      end

      context 'GPL2 with Markdown formatting' do
        let(:license) { Licensee::License.find('gpl-2.0') }
        let(:fixture) { 'gpl-2.0_markdown_headings' }

        it 'matches to GPL2' do
          expect(project.license).to eql(license)
        end
      end

      context 'Artistic with Markdown formatting' do
        let(:license) { Licensee::License.find('artistic-2.0') }
        let(:fixture) { 'artistic-2.0_markdown' }

        it 'matches to Artistic' do
          expect(project.license).to eql(license)
        end
      end

      context 'BSD-3-Clause numbered and bulleted' do
        let(:license) { Licensee::License.find('bsd-3-clause') }
        let(:fixture) { 'bsd-3-lists' }

        it 'determines the project is BSD-3-Clause' do
          expect(project.license).to eql(license)
        end
      end

      context 'BSD-3-Clause no-endorsement name with slashes' do
        let(:license) { Licensee::License.find('bsd-3-clause') }
        let(:fixture) { 'bsd-3-noendorseslash' }

        it 'determines the project is BSD-3-Clause' do
          expect(project.license).to eql(license)
        end
      end

      context 'BSD-3-Clause author/owner variant' do
        let(:license) { Licensee::License.find('bsd-3-clause') }
        let(:fixture) { 'bsd-3-authorowner' }

        it 'determines the project is BSD-3-Clause' do
          expect(project.license).to eql(license)
        end
      end

      context 'BSD-2-Clause author variant' do
        let(:license) { Licensee::License.find('bsd-2-clause') }
        let(:fixture) { 'bsd-2-author' }

        it 'determines the project is BSD-2-Clause' do
          expect(project.license).to eql(license)
        end
      end

      context 'HTML license file' do
        let(:license) { Licensee::License.find('epl-1.0') }
        let(:fixture) { 'html' }

        it 'matches to GPL3' do
          expect(project.license).to eql(license)
        end
      end

      context 'Vim license file' do
        let(:license) { Licensee::License.find('vim') }
        let(:fixture) { 'vim' }

        it 'matches to Vim' do
          expect(project.license).to eql(license)
        end
      end

      context 'CC-BY-SA no CC licensor statement license file' do
        let(:license) { Licensee::License.find('cc-by-sa-4.0') }
        let(:fixture) { 'cc-by-sa-nocclicensor' }

        it 'matches to CC-BY-SA' do
          expect(project.license).to eql(license)
        end
      end

      context 'CC-BY-SA markdown links file' do
        let(:license) { Licensee::License.find('cc-by-sa-4.0') }
        let(:fixture) { 'cc-by-sa-mdlinks' }

        it 'matches to CC-BY-SA' do
          expect(project.license).to eql(license)
        end
      end

      context 'MIT with byte order mark' do
        let(:license) { Licensee::License.find('mit') }
        let(:fixture) { 'bom' }

        it 'matches to MIT' do
          expect(project.license).to eql(license)
        end
      end

      context 'with the license file stubbed' do
        let(:project_path) { Dir.mktmpdir }

        let(:write_file) do
          lambda do |filename, file_content|
            File.write(File.expand_path(filename, project_path), file_content)
            git_init(project_path) if initialize_git_repo
          end
        end

        after { FileUtils.rm_rf(project_path) }

        filenames = [
          'LICENSE.md', 'LICENSE.txt', 'LICENSE.md', 'LiCeNSe.Txt',
          'LICENSE-MIT', 'MIT-LICENSE', 'licence', 'unlicense'
        ]
        filenames.each do |filename|
          it "matches the license file for #{filename}" do
            write_file.call(filename, content)
            project = project_type.new(project_path, **arguments)
            expect(project.license).to eql(license)
            expect(project.license_file.path).to eql(filename)
          end
        end

        it 'matches a package.json file' do
          write_file.call('package.json', '{"license": "mit"}')
          project = project_type.new(project_path, detect_packages: true)

          expect(project.license).to eql(Licensee::License.find('mit'))
          expect(project.package_file.path).to eql('package.json')
        end

        it 'matches a README file' do
          write_file.call('README', "## License\n#{Licensee::License.find('mit').content}")
          project = project_type.new(project_path, detect_readme: true)

          expect(project.license).to eql(Licensee::License.find('mit'))
          expect(project.readme_file.path).to eql('README')
        end

        it 'matches a DESCRIPTION file' do
          write_file.call('DESCRIPTION', "Package: test\nLicense: MIT")
          project = project_type.new(project_path, detect_packages: true)

          expect(project.license).to eql(Licensee::License.find('mit'))
          expect(project.package_file.path).to eql('DESCRIPTION')
        end
      end
    end
  end
end
