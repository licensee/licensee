# frozen_string_literal: true

module Fixture
end

RSpec.describe Fixture do
  fixtures.each do |fixture|
    context "the #{fixture} fixture" do
      subject(:project) { Licensee.project(path, detect_packages: true, detect_readme: true) }

      let(:path) { fixture_path(fixture) }
      let(:expectations) { fixture_licenses[fixture] || {} }

      def expected_license
        license_key = expectations['key']
        return Licensee::License.find(license_key) if license_key

        Licensee::License.find('none')
      end

      it 'has an expected license in fixtures-licenses.yml' do
        msg = +'Expected an entry in `'
        msg << fixture_path('fixtures-licenses.yml')
        msg << "` for the `#{fixture}` fixture. Please run "
        msg << 'script/dump-fixture-licenses and confirm the output.'
        expect(fixture_licenses).to have_key(fixture), msg
      end

      it 'detects the license' do
        expect(project.license).to eql(expected_license)
      end

      it 'returns the expected hash' do
        hash = project.license_file&.content_hash
        expect(hash).to eql(expectations['hash'])
      end

      it 'uses the expected matcher' do
        matcher = project.license_file&.matcher
        expected = matcher ? matcher.name.to_s : nil
        expect(expected).to eql(expectations['matcher'])
      end
    end
  end
end
