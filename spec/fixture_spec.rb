RSpec.describe 'fixture test' do
  fixtures.each do |fixture|
    let(:options) { { detect_packages: true, detect_readme: true } }

    context "the #{fixture} fixture" do
      let(:path) { fixture_path(fixture) }
      let(:other) { Licensee::License.find('other') }
      let(:none) { Licensee::License.find('none') }
      let(:expectations) { fixture_licenses[fixture] }

      subject { Licensee.project(path, options) }

      it 'has an expected license in fixtures-licenses.yml' do
        msg = "Expected an entry in `#{fixture_path('fixtures-licenses.yml')}`"
        msg << "` for the `#{fixture}` fixture. Please run "
        msg << 'script/dump-fixture-licenses and confirm the output.'
        expect(fixture_licenses).to have_key(fixture), msg
      end

      it 'detects the license' do
        expected = if expectations["key"]
          Licensee::License.find(expectations["key"])
        else
          none
        end

        expect(subject.license).to eql(expected)
      end

      it "returns the expected hash" do
        hash = subject.license_file&.content_hash
        expect(hash).to eql(expectations["hash"])
      end

      it "uses the expected matcher" do
        matcher = subject.license_file&.matcher&.name
        matcher = matcher.to_s if matcher
        expect(matcher).to eql(expectations["matcher"])
      end
    end
  end
end
