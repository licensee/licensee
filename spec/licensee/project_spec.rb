# File system-based project types
[Licensee::FSProject, Licensee::GitProject].each do |project_type|
  RSpec.describe project_type do
    let(:mit) { Licensee::License.find('mit') }
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
  end
end

# Tests for URI project
RSpec.describe Licensee::UriProject do
  let(:path) { 'https://localhost' }
  subject { described_class.new(path) }

  context 'reading files' do
    let(:files) { subject.send(:files) }

    it 'returns the file list' do
      expect(files.count).to eql(1)
      expect(files.first[:name]).to eql(path)
      expect(files.first).to have_key(:uri)
    end
  end
end
