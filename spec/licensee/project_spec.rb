[Licensee::FSProject, Licensee::GitProject].each do |project_type|
  RSpec.describe project_type do
    let(:mit) { Licensee::License.find('mit') }
    let(:other) { Licensee::License.find('other') }
    let(:fixture) { 'mit' }
    let(:path) { fixture_path(fixture) }
    subject { described_class.new(path) }

    if described_class == Licensee::GitProject
      before do
        Dir.chdir path do
          `git init`
          `git add .`
          `git commit -m 'initial commit'`
        end
      end

      after { FileUtils.rm_rf File.expand_path '.git', path }
    end

    it 'returns the license' do
      expect(subject.license).to be_a(Licensee::License)
      expect(subject.license).to eql(mit)
    end

    it 'returns the matched file' do
      expect(subject.matched_file).to be_a(Licensee::Project::LicenseFile)
      expect(subject.matched_file.filename).to eql('LICENSE.txt')
    end

    it 'returns the license file' do
      expect(subject.license_file).to be_a(Licensee::Project::LicenseFile)
      expect(subject.license_file.filename).to eql('LICENSE.txt')
    end

    it "doesn't return the readme" do
      expect(subject.readme_file).to be_nil
    end

    it "doesn't return the package file" do
      expect(subject.package_file).to be_nil
    end

    context 'reading files' do
      let(:files) { subject.send(:files) }

      it 'returns the file list' do
        expect(files.count).to eql(2)
        expect(files.first[:name]).to eql('LICENSE.txt')

        if described_class == Licensee::GitProject
          expect(files.first).to have_key(:oid)
        end
      end

      it "returns a file's content" do
        content = subject.send(:load_file, files.first)
        expect(content).to match('Permission is hereby granted')
      end

      if described_class == Licensee::FSProject
        context 'with search root argument' do
          let(:fixture) { 'license-in-parent-folder/license-folder/package' }
          let(:path) { fixture_path(fixture) }
          let(:license_folder) { 'license-in-parent-folder/license-folder' }
          let(:search_root) { fixture_path(license_folder) }
          let(:subject) { described_class.new(path, search_root: search_root) }
          let(:files) { subject.send(:files) }

          it 'looks for licenses in parent directories up to the search root' do
            # should not include the license in 'license-in-parent-folder' dir
            expect(files.count).to eql(1)
            expect(files.first[:name]).to eql('LICENSE.txt')
          end
        end

        context 'without search root argument' do
          let(:fixture) { 'license-in-parent-folder/license-folder/package' }

          it 'looks for licenses in current directory only' do
            expect(files.count).to eql(0)
          end
        end
      end
    end

    context 'encoding correctness' do
      let(:fixture) { 'copyright-encoding' }

      it "returns a file's content" do
        expect(subject.license_file.content).to match(
          'Copyright © 2013–2016 by Peder Ås, 王二麻子, and Seán Ó Rudaí'
        )
      end
    end

    context 'readme detection' do
      let(:fixture) { 'readme' }
      subject { described_class.new(path, detect_readme: true) }

      it 'returns the readme' do
        expect(subject.readme_file).to be_a(Licensee::Project::Readme)
        expect(subject.readme_file.filename).to eql('README.md')
      end

      it 'returns the license' do
        expect(subject.license).to be_a(Licensee::License)
        expect(subject.license).to eql(mit)
      end
    end

    context 'package manager detection' do
      let(:fixture) { 'gemspec' }

      # Using a `.gemspec` extension in the fixture breaks `gem release`
      before do
        FileUtils.cp("#{path}/project._gemspec", "#{path}/project.gemspec")
        if described_class == Licensee::GitProject
          Dir.chdir path do
            `git add project.gemspec`
            `git commit -m 'add real gemspec'`
          end
        end
      end

      after do
        FileUtils.rm("#{path}/project.gemspec")
      end

      subject { described_class.new(path, detect_packages: true) }

      it 'returns the package file' do
        expect(subject.package_file).to be_a(Licensee::Project::PackageInfo)
        expect(subject.package_file.filename).to eql('project.gemspec')
      end

      it 'returns the license' do
        expect(subject.license).to be_a(Licensee::License)
        expect(subject.license).to eql(mit)
      end
    end

    context 'multiple licenses' do
      let(:fixture) { 'multiple-license-files' }

      it 'returns other for license' do
        expect(subject.license).to eql(other)
      end

      it 'returns nil for matched_file' do
        expect(subject.matched_file).to be_nil
      end

      it 'returns nil for license_file' do
        expect(subject.license_file).to be_nil
      end

      it 'returns both licenses' do
        expect(subject.licenses.count).to eql(2)
        expect(subject.licenses.first).to eql(Licensee::License.find('mpl-2.0'))
        expect(subject.licenses.last).to eql(mit)
      end

      it 'returns both matched_files' do
        expect(subject.matched_files.count).to eql(2)
        expect(subject.matched_files.first.filename).to eql('LICENSE')
        expect(subject.matched_files.last.filename).to eql('LICENSE.txt')
      end

      it 'returns both license_files' do
        expect(subject.license_files.count).to eql(2)
        expect(subject.license_files.first.filename).to eql('LICENSE')
        expect(subject.license_files.last.filename).to eql('LICENSE.txt')
      end
    end

    context 'lgpl' do
      let(:gpl) { Licensee::License.find('gpl-3.0') }
      let(:lgpl) { Licensee::License.find('lgpl-3.0') }
      let(:fixture) { 'lgpl' }

      it 'license returns lgpl' do
        expect(subject.license).to eql(lgpl)
      end

      it 'matched_file returns copying.lesser' do
        expect(subject.matched_file).to_not be_nil
        expect(subject.matched_file.filename).to eql('COPYING.lesser')
      end

      it 'license_file returns copying.lesser' do
        expect(subject.license_file).to_not be_nil
        expect(subject.license_file.filename).to eql('COPYING.lesser')
      end

      it 'returns both licenses' do
        expect(subject.licenses.count).to eql(2)
        expect(subject.licenses.first).to eql(lgpl)
        expect(subject.licenses.last).to eql(gpl)
      end

      it 'returns both matched_files' do
        expect(subject.matched_files.count).to eql(2)
        expect(subject.matched_files.first.filename).to eql('COPYING.lesser')
        expect(subject.matched_files.last.filename).to eql('LICENSE')
      end

      it 'returns both license_files' do
        expect(subject.license_files.count).to eql(2)
        expect(subject.license_files.first.filename).to eql('COPYING.lesser')
        expect(subject.license_files.last.filename).to eql('LICENSE')
      end
    end
  end
end
