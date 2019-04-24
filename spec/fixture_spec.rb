RSpec.describe 'fixture test' do
  fixtures.each do |fixture|
    let(:options) { { detect_packages: true, detect_readme: true } }

    context "the #{fixture} fixture" do
      let(:path) { fixture_path(fixture) }
      let(:other) { Licensee::License.find('other') }
      let(:none) { Licensee::License.find('none') }
      let(:expected) do
        license_key = fixture_licenses[fixture]
        return none unless license_key

        Licensee::License.find(license_key)
      end

      subject { Licensee.project(path, options) }

      it 'has an expected license in fixtures-licenses.yml' do
        msg = "Expected an entry in `#{fixture_path('fixtures-licenses.yml')}`"
        msg << "` for the `#{fixture}` fixture. Please run "
        msg << 'script/dump-fixture-licenses and confirm the output.'
        expect(fixture_licenses).to have_key(fixture), msg
      end

      it 'detects the license' do
        expect(subject.license).to eql(expected)
      end
    end
  end
end
