RSpec.describe 'vendored licenes' do
  let(:filename) { 'LICENSE.txt' }
  let(:license_file) { Licensee::Project::LicenseFile.new(content, filename) }
  let(:detected_license) { license_file.license }
  let(:wtfpl) { Licensee::License.find('wtfpl') }

  Licensee.licenses(hidden: true).each do |license|
    next if license.pseudo_license?

    context "the #{license.meta['spdx-id'] || license.key} license" do
      let(:content_with_copyright) { sub_copyright_info(license.content) }
      let(:content) { content_with_copyright }

      it 'detects the license' do
        expect(detected_license).to eql(license)
      end

      context 'when modified' do
        let(:line_length) { 50 }
        let(:random_words) { 3 }
        let(:content_rewrapped) { wrap(content_with_copyright, line_length) }
        let(:content_with_random_words) do
          add_random_words(content_with_copyright, random_words)
        end

        context 'when re-wrapped' do
          let(:content) { content_rewrapped }

          it 'detects the license' do
            expect(detected_license).to eql(license)
          end
        end

        context 'with random words added' do
          let(:content) { content_with_random_words }

          it 'detects the license' do
            # WTFPL is too short to be mofifed and wrapped and still be detected
            expect(detected_license).to eql(license) unless license == wtfpl
          end
        end

        context 'when rewrapped with random words added' do
          let(:content) { wrap(content_with_random_words, line_length) }

          it 'detects the license' do
            # WTFPL is too short to be mofifed and wrapped and still be detected
            expect(detected_license).to eql(license) unless license == wtfpl
          end
        end
      end
    end
  end
end
