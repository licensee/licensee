# frozen_string_literal: true

RSpec.describe Licensee::ProjectFiles::ProjectFile do
  subject(:license_file) { Licensee::ProjectFiles::LicenseFile.new(content, filename) }

  let(:filename) { 'LICENSE.txt' }
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { mit.content }

  it 'stores the content' do
    expect(license_file.content).to eql(content)
  end

  it 'stores the filename' do
    expect(license_file.filename).to eql(filename)
  end

  it 'returns the matcher' do
    expect(license_file.matcher).to be_a(Licensee::Matchers::Exact)
  end

  it 'returns the confidence' do
    expect(license_file.confidence).to be(100)
  end

  it 'returns the license' do
    expect(license_file.license).to eql(mit)
  end

  context 'with additional metadata' do
    subject(:project_file) { described_class.new(content, name: filename, dir: Dir.pwd) }

    it 'stores the filename' do
      expect(project_file).to(satisfy { |file| file.filename == filename && file[:name] == filename })
    end

    it 'stores additional metadata' do
      expect(project_file[:dir]).to eql(Dir.pwd)
    end
  end

  context 'when calling #to_h' do
    let(:hash) { license_file.to_h }
    let(:expected) do
      {
        attribution:        'Copyright (c) [year] [fullname]',
        filename:           'LICENSE.txt',
        content:            mit.content.to_s,
        content_hash:       license_file.content_hash,
        content_normalized: license_file.content_normalized,
        matcher:            {
          name:       :exact,
          confidence: 100
        },
        matched_license:    'MIT'
      }
    end

    it 'Converts to a hash' do
      expect(hash).to eql(expected)
    end
  end
end
