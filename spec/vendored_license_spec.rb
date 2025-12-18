# frozen_string_literal: true

module VendoredLicense
end

RSpec.describe VendoredLicense do
  def filename = 'LICENSE.txt'

  def hash_change_msg
    msg = +'Did you update a vendored license? Run '
    msg << '`bundle exec script/hash-licenses`. '
    msg << 'Changes in license hashes must be a MINOR (or MAJOR) bump.'
    msg
  end

  Licensee.licenses(hidden: true).each do |license|
    next if license.pseudo_license?

    context "with the #{license.name} license" do
      let(:content) { sub_copyright_info(license) }
      let(:expected_hash) { license_hashes[license.key] }

      it 'detects the license' do
        expect(content).to be_detected_as(license)
      end

      it 'confidence and similarity scores are euqal' do
        license_file = Licensee::ProjectFiles::LicenseFile.new(content, filename)
        expect(license_file.confidence).to eq(license.similarity(license_file))
      end

      it 'has a cached content hash' do
        expect(expected_hash).not_to be_nil, hash_change_msg
      end

      it 'matches the expected content hash' do
        expect(license.content_hash).to eql(expected_hash), hash_change_msg
      end

      context 'when modified' do
        it 'detects the license without the title' do
          modified_file = Licensee::ProjectFiles::LicenseFile.new(content, filename)
          modified_file.send(:strip_title)
          content_without_title = modified_file.send(:_content)
          expect(content_without_title).to be_detected_as(license)
        end

        it 'detects the license with a double title' do
          double_titled = "#{license.name.sub('*', 'u')}\n\n#{content}"
          expect(double_titled).to be_detected_as(license)
        end

        it 'detects the license when re-wrapped' do
          line_length = 60
          content_rewrapped = Licensee::ContentHelper.wrap(content, line_length)
          expect(content_rewrapped).to be_detected_as(license)
        end

        it 'does not match the license with random words added' do
          random_words = 75
          content_with_random_words = add_random_words(content, random_words)
          expect(content_with_random_words).not_to be_detected_as(license)
        end

        it 'does not match the license when rewrapped with random words added' do
          line_length = 60
          random_words = 75
          content_with_random_words = add_random_words(content, random_words)
          rewrapped = Licensee::ContentHelper.wrap(content_with_random_words, line_length)
          expect(rewrapped).not_to be_detected_as(license)
        end
      end
    end
  end
end
