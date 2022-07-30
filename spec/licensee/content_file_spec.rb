# frozen_string_literal: true

RSpec.describe Licensee::ContentFile do
  # File may be passed as a string or as a hash, with or without a directory. Test all cases.
  ['bar', { name: 'bar', dir: '.' }, { name: 'bar' }, { name: 'bar', dir: './foo' }].each do |file|
    context "with file as #{file}" do
      subject(:content_file) { described_class.new(content, file) }

      let(:filename) { file.is_a?(Hash) ? file[:name] : file }
      let(:dir) { file.is_a?(Hash) ? file[:dir] : '.' }
      let(:real_dir) { dir || '.' } # Gracefully handle expectations when dir is nil
      let(:content) { 'Licensee is cool' }

      it 'stores the content' do
        expect(content_file.content).to eql(content)
      end

      it 'stores the filename' do
        expect(content_file.filename).to eql(filename)
      end

      it 'returns the directory' do
        expect(content_file.directory).to eql(real_dir)
      end

      it 'returns the path relative to root' do
        path = File.join(real_dir, filename)
        expect(content_file.path_relative_to_root).to eql(path)
      end
    end
  end
end
