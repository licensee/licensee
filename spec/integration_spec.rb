RSpec.describe 'integration test' do
  [Licensee::FSProject, Licensee::GitProject].each do |project_type|
    context "with a #{project_type} project" do
      let(:filename) { 'LICENSE' }
      let(:license) { Licensee::License.find('mit') }
      let(:other) { Licensee::License.find('other') }
      let(:content) { license.content }
      let(:license_path) { File.expand_path(filename, project_path) }
      let(:arguments) { {} }

      subject { project_type.new(project_path, arguments) }

      context 'fixtures' do
        let(:fixture) { 'mit' }
        let(:project_path) { fixture_path(fixture) }
        let(:git_path) { File.expand_path('.git', project_path) }

        if project_type == Licensee::GitProject
          before { git_init(project_path) }
          after { FileUtils.rm_rf(git_path) }
        end

        context 'with a folder named license' do
          let(:fixture) { 'license-folder' }

          it "doesn't match" do
            expect(subject.license).to be_nil
          end
        end

        context 'with LICENSE.lesser' do
          let(:license) { Licensee::License.find('lgpl-3.0') }
          let(:fixture) { 'lgpl' }

          it 'matches to LGPL' do
            expect(subject.license).to eql(license)
            expect(subject.license_file.path).to eql('COPYING.lesser')
          end
        end

        context 'with CC-BY-NC-SA' do
          let(:fixture) { 'cc-by-nc-sa' }

          it 'matches other' do
            expect(subject.license).to eql(other)
          end
        end

        context 'with CC-BY-ND' do
          let(:fixture) { 'cc-by-nd' }

          it 'matches other' do
            expect(subject.license).to eql(other)
          end
        end

        context 'MPL with HRs removed' do
          let(:license) { Licensee::License.find('mpl-2.0') }
          let(:fixture) { 'mpl-without-hrs' }

          it 'matches to MPL' do
            expect(subject.license).to eql(license)
          end
        end

        context 'GPL3 with instructions removed' do
          let(:license) { Licensee::License.find('gpl-3.0') }
          let(:fixture) { 'gpl3-without-instructions' }

          it 'matches to GPL3' do
            expect(subject.license).to eql(license)
          end
        end

        context 'DESCRIPTION file with a LICENSE file' do
          let(:license) { Licensee::License.find('mit') }
          let(:fixture) { 'description-license' }
          let(:arguments) { { detect_packages: true } }

          it 'matches' do
            expect(subject.license).to eql(license)
            expect(subject.package_file.path).to eql('DESCRIPTION')
          end
        end
      end

      context 'with the license file stubbed' do
        let(:project_path) { Dir.mktmpdir }

        before do
          File.write(license_path, content)
          git_init(project_path) if project_type == Licensee::GitProject
        end

        after { FileUtils.rm_rf(project_path) }

        [
          'LICENSE.md', 'LICENSE.txt', 'LICENSE.md', 'LiCeNSe.Txt',
          'LICENSE-MIT', 'MIT-LICENSE', 'licence', 'unlicense'
        ].each do |filename|
          context "with a #{filename} file" do
            let(:filename) { filename }

            it 'matches the license file' do
              expect(subject.license).to eql(license)
              expect(subject.license_file.path).to eql(filename)
            end
          end
        end

        context 'an unlicensed project' do
          let(:content) { '' }

          it "doesn't match" do
            expect(subject.license).to eql(other)
            expect(subject.license_file.path).to eql('LICENSE')
          end
        end

        context 'a package.json file' do
          let(:content) { '{"license": "mit"}' }
          let(:filename) { 'package.json' }
          let(:license) { Licensee::License.find('mit') }
          let(:arguments) { { detect_packages: true } }

          it 'matches' do
            expect(subject.license).to eql(license)
            expect(subject.package_file.path).to eql(filename)
          end
        end

        context 'a README file' do
          let(:content) { "## License\n#{license.content}" }
          let(:filename) { 'README' }
          let(:license) { Licensee::License.find('mit') }
          let(:arguments) { { detect_readme: true } }

          it 'matches' do
            expect(subject.license).to eql(license)
            expect(subject.readme_file.path).to eql(filename)
          end
        end

        context 'a DESCRIPTION file' do
          let(:content) { "Package: test\nLicense: MIT" }
          let(:filename) { 'DESCRIPTION' }
          let(:license) { Licensee::License.find('mit') }
          let(:arguments) { { detect_packages: true } }

          it 'matches' do
            expect(subject.license).to eql(license)
            expect(subject.package_file.path).to eql(filename)
          end
        end
      end
    end
  end
end
