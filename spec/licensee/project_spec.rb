# frozen_string_literal: true

[
  Licensee::Projects::FSProject,
  Licensee::Projects::GitProject,
  Licensee::Projects::GitHubProject
].each do |project_type|
  RSpec.describe project_type do
    subject { described_class.new(path) }

    def stubbed_org = '_licensee_test_fixture'
    def api_base = 'https://api.github.com/repos'
    def mit = Licensee::License.find('mit')
    def other = Licensee::License.find('other')
    let(:fixture) { 'mit' }
    let(:path) { fixture_path(fixture) }

    if described_class == Licensee::Projects::GitHubProject
      let(:path) { "https://github.com/#{stubbed_org}/#{fixture}" }
    end

    before do
      if described_class == Licensee::Projects::GitProject
        git_init(path)
      elsif described_class == Licensee::Projects::GitHubProject
        stub_request(
          :get, "#{api_base}/#{stubbed_org}/#{fixture}/contents/"
        ).to_return(
          status:  200,
          body:    fixture_root_contents_from_api(fixture),
          headers: { 'Content-Type' => 'application/json' }
        )

        fixture_root_files(fixture).each do |file|
          relative_path = File.basename(file)
          parts = [api_base, stubbed_org, fixture, 'contents', relative_path]
          stub_request(:get, parts.join('/'))
            .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
            .to_return(status: 200, body: File.read(file))
        end
      end
    end

    if described_class == Licensee::Projects::GitProject
      after do
        subject.close
        FileUtils.rm_rf File.expand_path '.git', path
      end
    end

    if described_class == Licensee::Projects::GitProject
      context 'when initialized with a repo' do
        subject { described_class.new(repo) }

        let(:repo) { Rugged::Repository.new(path) }

        it 'returns the repository' do
          expect(subject.repository).to be_a(Rugged::Repository)
        end
      end

      context 'when initialized with a revision' do
        let(:revision) { subject.repository.last_commit.oid }

        before do
          subject.instance_variable_set(:@revision, revision)
        end

        it 'returns the commit' do
          expect(subject.send(:commit).oid).to eql(revision)
        end
      end
    end

    it 'returns the license' do
      expect(subject.license).to eql(mit)
    end

    it 'returns the matched file' do
      expect(subject.matched_file).to have_attributes(filename: 'LICENSE.txt')
    end

    it 'returns the license file' do
      expect(subject.license_file).to have_attributes(filename: 'LICENSE.txt')
    end

    it "doesn't return the readme" do
      expect(subject.readme_file).to be_nil
    end

    it "doesn't return the package file" do
      expect(subject.package_file).to be_nil
    end

    context 'when reading files' do
      def files = subject.send(:files)

      it 'returns the file list' do
        expect(files).to satisfy do |values|
          next false unless values.count == 2
          next false if values.find { |f| f[:name] == 'LICENSE.txt' }.nil?

          described_class != Licensee::Projects::GitProject || values.first.key?(:oid)
        end
      end

      it "returns a file's content" do
        content = subject.send(:load_file, files.first)
        expect(content).to match('Permission is hereby granted')
      end

      if described_class == Licensee::Projects::FSProject
        context 'with search root argument' do
          subject { described_class.new(path, search_root: search_root) }

          let(:fixture) { 'license-in-parent-folder/license-folder/package' }
          let(:search_root) { fixture_path('license-in-parent-folder/license-folder') }

          it 'looks for licenses in parent directories up to the search root' do
            # should not include the license in 'license-in-parent-folder' dir
            expect(files).to(satisfy { |values| values.one? && values.first[:name] == 'LICENSE.txt' })
          end
        end

        context 'without search root argument' do
          let(:fixture) { 'license-in-parent-folder/license-folder/package' }

          it 'looks for licenses in current directory only' do
            expect(files.count).to be(0)
          end
        end
      end
    end

    context 'when checking encoding correctness' do
      let(:fixture) { 'copyright-encoding' }

      it "returns a file's content" do
        expect(subject.license_file.content).to match(
          'Copyright © 2013–2016 by Peder Ås, 王二麻子, and Seán Ó Rudaí'
        )
      end
    end

    context 'when detecting readme' do
      subject { described_class.new(path, detect_readme: true) }

      let(:fixture) { 'readme' }

      it 'returns the readme' do
        expect(subject.readme_file).to satisfy do |file|
          file.is_a?(Licensee::ProjectFiles::ReadmeFile) && file.filename == 'README.md'
        end
      end

      it 'returns the license' do
        expect(subject.license).to eql(mit)
      end
    end

    context 'when detecting package manager files' do
      subject { described_class.new(path, detect_packages: true) }

      let(:fixture) { 'gemspec' }

      def gemspec_path = "#{fixture_path(fixture)}/project.gemspec"

      # Using a `.gemspec` extension in the fixture breaks `gem release`
      before do
        from = "#{fixture_path(fixture)}/project._gemspec"
        FileUtils.cp(from, gemspec_path)
        if described_class == Licensee::Projects::GitProject
          Dir.chdir fixture_path(fixture) do
            `git add project.gemspec`
            `git commit -m 'add real gemspec'`
          end
        end
        next unless described_class == Licensee::Projects::GitHubProject

        stub_request(
          :get, "#{api_base}/#{stubbed_org}/#{fixture}/contents/"
        ).to_return(
          status:  200,
          body:    fixture_root_contents_from_api(fixture),
          headers: { 'Content-Type' => 'application/json' }
        )

        file = fixture_path "#{fixture}/project.gemspec"
        relative_path = File.basename(file)
        parts = [api_base, stubbed_org, fixture, 'contents', relative_path]
        stub_request(:get, parts.join('/'))
          .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
          .to_return(status: 200, body: File.read(file))
      end

      after do
        FileUtils.rm(gemspec_path)
      end

      it 'returns the package file' do
        expected = Licensee::ProjectFiles::PackageManagerFile
        expect(subject.package_file).to satisfy do |file|
          file.is_a?(expected) && file.filename == 'project.gemspec'
        end
      end

      it 'returns the license' do
        expect(subject.license).to eql(mit)
      end
    end

    context 'with multiple licenses' do
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
        expect(subject.licenses.map(&:key)).to eql(%w[mpl-2.0 mit])
      end

      it 'returns both matched_files' do
        expect(subject.matched_files.map(&:filename)).to eql(%w[LICENSE LICENSE.txt])
      end

      it 'returns both license_files' do
        expect(subject.license_files.map(&:filename)).to eql(%w[LICENSE LICENSE.txt])
      end
    end

    context 'with lgpl' do
      let(:fixture) { 'lgpl' }

      def gpl = Licensee::License.find('gpl-3.0')
      def lgpl = Licensee::License.find('lgpl-3.0')

      it 'license returns lgpl' do
        expect(subject.license).to eql(lgpl)
      end

      it 'matched_file returns copying.lesser' do
        expect(subject.matched_file).to have_attributes(filename: 'COPYING.lesser')
      end

      it 'license_file returns copying.lesser' do
        expect(subject.license_file).to have_attributes(filename: 'COPYING.lesser')
      end

      it 'returns both licenses' do
        expect(subject.licenses.map(&:key)).to eql(%w[lgpl-3.0 gpl-3.0])
      end

      it 'returns both matched_files' do
        expect(subject.matched_files.map(&:filename)).to eql(%w[COPYING.lesser LICENSE])
      end

      it 'returns both license_files' do
        expect(subject.license_files.map(&:filename)).to eql(%w[COPYING.lesser LICENSE])
      end
    end

    context 'with a copyright file' do
      let(:fixture) { 'mit-with-copyright' }

      it 'returns MIT' do
        expect(subject.license).to eql(mit)
      end
    end

    context 'when calling #to_h' do
      it 'Converts to a hash' do
        expected = {
          licenses:      subject.licenses.map(&:to_h),
          matched_files: subject.matched_files.map(&:to_h)
        }

        expect(subject.to_h).to eql(expected)
      end
    end
  end
end
