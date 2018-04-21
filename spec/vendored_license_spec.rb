RSpec.describe 'vendored licenses' do
  let(:filename) { 'LICENSE.txt' }
  let(:license_file) do
    Licensee::ProjectFiles::LicenseFile.new(content, filename)
  end
  let(:detected_license) { license_file.license if license_file }
  let(:wtfpl) { Licensee::License.find('wtfpl') }

  Licensee.licenses(hidden: true).each do |license|
    next if license.pseudo_license?

    context "the #{license.name} license" do
      let(:content_with_copyright) { sub_copyright_info(license) }
      let(:content) { content_with_copyright }

      it 'detects the license' do
        skip if license.key == 'ncsa'
        expect(content).to be_detected_as(license)
      end

      context 'when modified' do
        let(:line_length) { 60 }
        let(:random_words) { 75 }
        let(:content_rewrapped) do
          Licensee::ContentHelper.wrap(content_with_copyright, line_length)
        end
        let(:content_with_random_words) do
          add_random_words(content_with_copyright, random_words)
        end

        context 'without the title' do
          let(:content) { wtfpl.send :strip_title, content_with_copyright }

          it 'detects the license' do
            skip if license.key == 'ncsa'
            expect(content).to be_detected_as(license)
          end
        end

        context 'with a double title' do
          let(:content) do
            "#{license.name.sub('*', 'u')}\n\n#{content_with_copyright}"
          end

          it 'detects the license' do
            skip if license.key == 'ncsa'
            expect(content).to be_detected_as(license)
          end
        end

        context 'when re-wrapped' do
          let(:content) { content_rewrapped }

          it 'detects the license' do
            skip if license.key == 'ncsa'
            expect(content).to be_detected_as(license)
          end
        end

        context 'with random words added' do
          let(:content) { content_with_random_words }

          it 'does not match the license' do
            expect(content).to_not be_detected_as(license)
          end
        end

        context 'when rewrapped with random words added' do
          let(:content) do
            Licensee::ContentHelper.wrap(content_with_random_words, line_length)
          end

          it 'does not match the license' do
            expect(content).to_not be_detected_as(license)
          end
        end
      end
    end
  end
end
