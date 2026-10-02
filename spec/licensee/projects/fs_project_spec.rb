# frozen_string_literal: true

RSpec.describe Licensee::Projects::FSProject do
  let(:temporary_dir) { Dir.mktmpdir('licensee-paths-') }
  let(:mit) { Licensee::License.find('mit') }
  let(:apache2) { Licensee::License.find('apache-2.0') }

  after { FileUtils.remove_entry(temporary_dir) }

  directory_names = ['checkout[1]', 'checkout{a,b}']
  directory_names += ['checkout*literal', 'checkout?literal', 'checkout\\literal'] unless File::ALT_SEPARATOR

  directory_names.each do |directory_name|
    context "when the directory is named #{directory_name}" do
      subject(:project) { described_class.new(path) }

      let(:path) { File.join(temporary_dir, directory_name) }

      before do
        FileUtils.mkdir_p(path)
        File.write(File.join(path, 'LICENSE'), mit.content)
      end

      it 'detects the license at the literal path' do
        expect(project.license).to eql(mit)
      end

      it 'lists each file once' do
        expect(project.send(:files)).to eql([{ name: 'LICENSE', dir: '.' }])
      end
    end
  end

  context 'when the search root contains brackets' do
    subject(:project) { described_class.new(path, search_root: search_root) }

    let(:search_root) { File.join(temporary_dir, 'checkout[1]') }
    let(:path) { File.join(search_root, 'package') }

    before do
      FileUtils.mkdir_p(path)
      File.write(File.join(search_root, 'LICENSE'), mit.content)
    end

    it 'detects the license in the parent directory' do
      expect(project.license).to eql(mit)
    end

    it 'keeps the matched path relative to the project' do
      expect(project.matched_file.path).to eql('../LICENSE')
    end
  end

  context 'when scanning a file inside a directory containing brackets' do
    let(:directory) { File.join(temporary_dir, 'checkout[1]') }
    let(:path) { File.join(directory, 'LICENSE') }

    before do
      FileUtils.mkdir_p(directory)
      File.write(path, mit.content)
    end

    it 'detects the requested file through the public API' do
      expect(Licensee.license(path)).to eql(mit)
    end
  end

  context 'when a file name contains brackets' do
    subject(:project) { described_class.new(path) }

    let(:path) { File.join(temporary_dir, 'LICENSE-[1].txt') }

    before do
      File.write(path, mit.content)
      File.write(File.join(temporary_dir, 'LICENSE-1.txt'), apache2.content)
    end

    it 'detects the license in the requested file' do
      expect(project.license).to eql(mit)
    end

    it 'does not select the sibling matched by a glob' do
      expect(project.send(:files)).to eql([{ name: 'LICENSE-[1].txt', dir: '.' }])
    end
  end

  context 'when the search root is not an ancestor' do
    let(:search_root) { File.join(temporary_dir, 'checkout') }

    %w[unrelated checkout-copy].each do |directory_name|
      it "rejects the #{directory_name} directory" do
        path = File.join(temporary_dir, directory_name)
        expect { described_class.new(path, search_root: search_root) }
          .to raise_error(RuntimeError, 'Search root must be the project path directory or its ancestor')
      end
    end
  end
end
