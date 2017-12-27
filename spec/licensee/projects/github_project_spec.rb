RSpec.describe Licensee::Projects::GitHubProject do
  let(:repo) { 'benbalter/licensee' }
  let(:github_url) { "https://github.com/#{repo}" }
  let(:mit) { Licensee::License.find('mit') }
  let(:readme_file) { File.read(fixture_path('mit/README.md')) }
  let(:license_file) { File.read(fixture_path('mit/LICENSE.txt')) }
  subject(:instance) { described_class.new(github_url) }

  describe '#initialize' do
    context 'with a GitHub URI' do
      it 'should set @repo' do
        expect(instance.repo).to eq(repo)
      end
    end

    context 'with a GitHub git URI' do
      let(:github_url) { "https://github.com/#{repo}.git" }

      it 'should set @repo, stripping the trailing extension' do
        expect(instance.repo).to eq(repo)
      end
    end

    context 'with a non-GitHub URI' do
      let(:github_url) { "https://gitlab.com/#{repo}" }

      it 'should raise an ArgumentError' do
        expect { instance }.to raise_error(ArgumentError)
      end
    end

    context 'with a local folder' do
      let(:github_url) { fixture_path('mit') }

      it 'should raise an ArgumentError' do
        expect { instance }.to raise_error(ArgumentError)
      end
    end
  end

  context 'when the repo exists' do
    before do
      allow(Octokit)
        .to receive(:contents)
        .with('benbalter/licensee')
        .and_return([
                      {
                        name:         'LICENSE.txt',
                        path:         'LICENSE.txt',
                        sha:          'sha1',
                        size:         1072,
                        url:          'https://api.github.com/repos/benbalter/licensee/contents/LICENSE.txt?ref=master',
                        html_url:     'https://github.com/benbalter/licensee/blob/master/LICENSE.txt',
                        git_url:      'https://api.github.com/repos/benbalter/licensee/git/blobs/sha1',
                        download_url: 'https://raw.githubusercontent.com/benbalter/licensee/master/LICENSE.txt',
                        type:         'file',
                        _links:       {}
                      },
                      { name:         'README.md',
                        path:         'README.md',
                        sha:          'sha2',
                        size:         13_420,
                        url:          'https://api.github.com/repos/benbalter/licensee/contents/README.md?ref=master',
                        html_url:     'https://github.com/benbalter/licensee/blob/master/README.md',
                        git_url:      'https://api.github.com/repos/benbalter/licensee/git/blobs/sha2',
                        download_url: 'https://raw.githubusercontent.com/benbalter/licensee/master/README.md',
                        type:         'file',
                        _links:       {} }
                    ])

      allow(Octokit)
        .to receive(:contents)
        .with(repo, path:   'LICENSE.txt',
                    accept: 'application/vnd.github.v3.raw')
        .and_return(license_file)

      allow(Octokit)
        .to receive(:contents)
        .with(repo, path: 'README.md', accept: 'application/vnd.github.v3.raw')
        .and_return(readme_file)
    end

    it 'returns the license' do
      expect(subject.license).to be_a(Licensee::License)
      expect(subject.license).to eql(mit)
    end

    it 'returns the matched file' do
      expect(subject.matched_file).to be_a(Licensee::ProjectFiles::LicenseFile)
      expect(subject.matched_file.filename).to eql('LICENSE.txt')
    end

    it 'returns the license file' do
      expect(subject.license_file).to be_a(Licensee::ProjectFiles::LicenseFile)
      expect(subject.license_file.filename).to eql('LICENSE.txt')
    end

    it "doesn't return the readme" do
      expect(subject.readme_file).to be_nil
    end

    it "doesn't return the package file" do
      expect(subject.package_file).to be_nil
    end

    context 'readme detection' do
      subject { described_class.new(github_url, detect_readme: true) }

      it 'returns the readme' do
        expect(subject.readme_file).to be_a(Licensee::ProjectFiles::ReadmeFile)
        expect(subject.readme_file.filename).to eql('README.md')
      end

      it 'returns the license' do
        expect(subject.license).to be_a(Licensee::License)
        expect(subject.license).to eql(mit)
      end
    end
  end

  context 'when the repo cannot be found' do
    let(:github_url) { 'https://github.com/benbalter/not-foundsss' }

    before do
      allow(Octokit)
        .to receive(:contents).with(anything).and_raise(Octokit::NotFound)
    end

    it 'raises a RepoNotFound error' do
      expect { subject.license }.to raise_error(described_class::RepoNotFound)
    end
  end
end
