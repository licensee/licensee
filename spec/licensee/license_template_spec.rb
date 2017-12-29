RSpec.describe Licensee::LicenseTemplate do
  let(:spdx_id) { 'ISC' }
  let(:key) { 'isc' }
  let(:license) { Licensee::License.find(key) }
  subject { described_class.new(spdx_id) }

  context 'class methods' do
    it 'returns the template path' do
      path = '../../vendor/spdx-license-list/template'
      expected = File.expand_path path, __dir__
      expect(described_class.template_dir).to eql(expected)
    end

    it 'returns a template with a given key' do
      expect(described_class.find(key)).to eql(subject)
    end

    it 'returns all licenses' do
      expect(described_class.all).to be_an(Array)
      expect(described_class.all).to include(subject)
    end
  end

  it 'stores the SPDX ID' do
    expect(subject.spdx_id).to eql(spdx_id)
  end

  it 'builds the regex' do
    expect(subject.regex).to be_a(Regexp)
    expect(subject.regex.to_s).to include('(?<copyrightholderliability>.+?)')
  end

  it 'knows the template path' do
    expect(subject.send(:path)).to be_an_existing_file
  end

  it 'reads template content' do
    expect(subject.send(:content)).to match(/Internet Systems Consortium/)
  end

  it 'escapes the content' do
    expect(subject.send(:content_escaped)).to match("\.")
  end

  it 'extracts fields' do
    fields = subject.send(:fields)
    expect(fields.count).to eql(4)
    expect(fields.first[:name]).to eql('title')
    expect(fields.first[:original]).to eql('isc license')
    expect(fields.first[:match]).to eql('(the )?isc license( \\(isc[l]?\\))?:?')
  end

  it 'matches the license' do
    expect(subject.regex).to match(license.content_normalized)
  end

  context 'matching' do
    Licensee::License.all(hidden: true, psuedo: false).each do |license|
      context "the #{license.key} license" do
        let(:license_template) { described_class.find(license.key) }
        let(:license_text) { sub_copyright_info(license) }
        let(:license_file) do
          Licensee::ProjectFiles::LicenseFile.new(license_text, 'LICENSE')
        end

        it 'matches' do
          skip 'License variation' if ['eupl-1.1', 'epl-1.0'].include?(license.key)
          puts license_template.regex
          puts '---'
          puts license_file.content_normalized
          expect(license_template.regex).to match(license_file.content_normalized)
        end
      end
    end
  end
end
