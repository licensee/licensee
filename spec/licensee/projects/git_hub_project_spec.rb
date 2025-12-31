# frozen_string_literal: true

RSpec.describe Licensee::Projects::GitHubProject do
  subject(:instance) { described_class.new(github_url) }

  let(:repo) { 'benbalter/licensee' }

  def github_url = "https://github.com/#{repo}"
  def mit = Licensee::License.find('mit')
  def mit_readme_file = File.read(fixture_path('mit/README.md'))
  def mit_license_file = File.read(fixture_path('mit/LICENSE.txt'))
  def apache2 = Licensee::License.find('apache-2.0')
  def apache2_license_file = File.read(fixture_path('apache-with-readme-notice/LICENSE'))

  describe '#initialize' do
    context 'with a GitHub URI' do
      it 'sets @repo' do
        expect(instance.repo).to eq(repo)
      end
    end

    context 'with a GitHub git URI' do
      let(:github_url) { "https://github.com/#{repo}.git" }

      it 'sets @repo, stripping the trailing extension' do
        expect(instance.repo).to eq(repo)
      end
    end

    context 'with a non-GitHub URI' do
      let(:github_url) { "https://gitlab.com/#{repo}" }

      it 'raises an ArgumentError' do
        expect { instance }.to raise_error(ArgumentError)
      end
    end

    context 'with a local folder' do
      let(:github_url) { fixture_path('mit') }

      it 'raises an ArgumentError' do
        expect { instance }.to raise_error(ArgumentError)
      end
    end
  end

  context 'when the repo exists' do
    before do
      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/')
        .to_return(
          status:  200,
          body:    fixture_contents('webmock/licensee.json'),
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSE.txt')
        .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
        .to_return(status: 200, body: mit_license_file)

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/README.md')
        .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
        .to_return(status: 200, body: mit_readme_file)

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSES')
        .to_return(status: 404)
    end

    it 'returns the license' do
      expect(instance.license).to eql(mit)
    end

    it 'returns the matched file' do
      expect(instance.matched_file).to satisfy do |file|
        file.is_a?(Licensee::ProjectFiles::LicenseFile) && file.filename == 'LICENSE.txt'
      end
    end

    it 'returns the license file' do
      expect(instance.license_file).to satisfy do |file|
        file.is_a?(Licensee::ProjectFiles::LicenseFile) && file.filename == 'LICENSE.txt'
      end
    end

    it "doesn't return the readme" do
      expect(instance.readme_file).to be_nil
    end

    it "doesn't return the package file" do
      expect(instance.package_file).to be_nil
    end

    context 'when detecting readme' do
      subject(:instance) { described_class.new(github_url, detect_readme: true) }

      it 'returns the readme' do
        expect(instance.readme_file).to satisfy do |file|
          file.is_a?(Licensee::ProjectFiles::ReadmeFile) && file.filename == 'README.md'
        end
      end

      it 'returns the license' do
        expect(instance.license).to eql(mit)
      end
    end

    context 'when initialized with a ref' do
      subject(:instance) { described_class.new(github_url, ref: 'my-ref') }

      before do
        stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/?ref=my-ref')
          .to_return(
            status:  200,
            body:    fixture_contents('webmock/licensee_alternate_ref.json'),
            headers: { 'Content-Type' => 'application/json' }
          )

        stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSE?ref=my-ref')
          .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
          .to_return(status: 200, body: apache2_license_file)

        stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSES?ref=my-ref')
          .to_return(status: 404)
      end

      it 'returns the ref' do
        expect(instance.ref).to eql('my-ref')
      end

      it 'returns query params' do
        expect(instance.send(:query_params)).to eql({ ref: instance.ref })
      end

      it 'returns the license' do
        expect(instance.license).to eql(apache2)
      end
    end
  end

  context 'when repo has LICENSES/ dir' do
    before do
      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/')
        .to_return_json(
          status:  200,
          body:    [
            {
              name:         'LICENSES',
              path:         'LICENSES',
              sha:          'sha1',
              size:         0,
              url:          'https://api.github.com/repos/benbalter/licensee/contents/LICENSES?ref=master',
              html_url:     'https://github.com/benbalter/licensee/tree/master/LICENSES',
              git_url:      'https://api.github.com/repos/benbalter/licensee/git/trees/sha1',
              download_url: nil,
              type:         'dir',
              _links:       {}
            }
          ],
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSES')
        .to_return_json(
          status:  200,
          body:    [
            {
              name:         'MIT.txt',
              path:         'LICENSES/MIT.txt',
              sha:          'sha1',
              size:         1072,
              url:          'https://api.github.com/repos/benbalter/licensee/contents/LICENSES/MIT.txt?ref=master',
              html_url:     'https://github.com/benbalter/licensee/blob/master/LICENSES/MIT.txt',
              git_url:      'https://api.github.com/repos/benbalter/licensee/git/blobs/sha1',
              download_url: 'https://raw.githubusercontent.com/benbalter/licensee/master/LICENSES/MIT.txt',
              type:         'file',
              _links:       {}
            }
          ],
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSES/MIT.txt')
        .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
        .to_return(status: 200, body: mit_license_file)
    end

    it 'returns both licenses' do
      expect(subject.licenses.count).to be(1)
      expect(subject.licenses.first).to eql(mit)
    end
  end

  context 'when repo has LICENSES/ dir with multiple licenses' do
    before do
      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/')
        .to_return_json(
          status:  200,
          body:    [
            {
              name:         'LICENSES',
              path:         'LICENSES',
              sha:          'sha1',
              size:         0,
              url:          'https://api.github.com/repos/benbalter/licensee/contents/LICENSES?ref=master',
              html_url:     'https://github.com/benbalter/licensee/tree/master/LICENSES',
              git_url:      'https://api.github.com/repos/benbalter/licensee/git/trees/sha1',
              download_url: nil,
              type:         'dir',
              _links:       {}
            }
          ],
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSES')
        .to_return_json(
          status:  200,
          body:    [
            {
              name:         'MIT.txt',
              path:         'LICENSES/MIT.txt',
              sha:          'sha1',
              size:         1072,
              url:          'https://api.github.com/repos/benbalter/licensee/contents/LICENSES/MIT.txt?ref=master',
              html_url:     'https://github.com/benbalter/licensee/blob/master/LICENSES/MIT.txt',
              git_url:      'https://api.github.com/repos/benbalter/licensee/git/blobs/sha1',
              download_url: 'https://raw.githubusercontent.com/benbalter/licensee/master/LICENSES/MIT.txt',
              type:         'file',
              _links:       {}
            },
            {
              name:         'APACHE-2.0.txt',
              path:         'LICENSES/APACHE-2.0.txt',
              sha:          'sha2',
              size:         1072,
              url:          'https://api.github.com/repos/benbalter/licensee/contents/LICENSES/APACHE-2.0.txt?ref=master',
              html_url:     'https://github.com/benbalter/licensee/blob/master/LICENSES/APACHE-2.0.txt',
              git_url:      'https://api.github.com/repos/benbalter/licensee/git/blobs/sha2',
              download_url: 'https://raw.githubusercontent.com/benbalter/licensee/master/LICENSES/APACHE-2.0.txt',
              type:         'file',
              _links:       {}
            }
          ],
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSES/MIT.txt')
        .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
        .to_return(status: 200, body: mit_license_file)

      stub_request(:get, 'https://api.github.com/repos/benbalter/licensee/contents/LICENSES/APACHE-2.0.txt')
        .with(headers: { 'accept' => 'application/vnd.github.v3.raw' })
        .to_return(status: 200, body: apache2_license_file)
    end

    it 'returns both licenses' do
      expect(subject.licenses.count).to be(2)
      expect(subject.licenses.first).to eql(mit)
      expect(subject.licenses.last).to eql(apache2)
    end
  end

  context 'when the repo cannot be found' do
    let(:repo) { 'benbalter/not-foundsss' }

    before do
      stub_request(:get, 'https://api.github.com/repos/benbalter/not-foundsss/contents/')
        .to_return(status: 404)
    end

    it 'raises a RepoNotFound error' do
      expect { instance.license }.to raise_error(described_class::RepoNotFound)
    end
  end
end
