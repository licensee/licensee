# frozen_string_literal: true

RSpec.describe Licensee::IgnoreFile do
  subject(:ignore_file) { described_class.new(content, file) }

  let(:filename) { 'license.txt' }
  let(:file) { { name: filename } }
  let(:content) do
    <<-CONTENT
      licensee.gemspec
      script/detect-license.sh
    CONTENT
  end

  let(:ignore_file_path) { '.licensee-ignore' }

  it 'stores the content' do
    expect(ignore_file.content).to eql(content)
  end

  it 'detects ignore files' do
    expect(described_class.name_score(ignore_file_path)).to be(1)
  end

  context 'with a non-matching filename' do
    let(:filename) { 'foo.txt' }

    it 'does not detect ignore files' do
      expect(described_class.name_score(filename)).to be(0)
    end
  end

  it 'parses paths' do
    expect(ignore_file.ignored_paths).to eql(['licensee.gemspec', 'script/detect-license.sh', '.licensee-ignore'])
  end

  context 'with an ignored file' do
    let(:filename) { 'licensee.gemspec' }

    it 'is ignored' do
      expect(ignore_file.ignored?(file)).to be true
    end
  end

  context 'with an ignored file in a subdirectory' do
    let(:filename) { 'script/detect-license.sh' }

    it 'is ignored' do
      expect(ignore_file.ignored?(file)).to be true
    end
  end

  context 'with a non-ignored file' do
    let(:filename) { 'LICENSE.txt' }

    it 'is ignored' do
      expect(ignore_file.ignored?(file)).to be false
    end
  end

  context 'with a glob pattern' do
    let(:content) { '*.txt' }
    let(:filename) { 'LICENSE.txt' }

    it 'is ignored' do
      expect(ignore_file.ignored?(file)).to be true
    end
  end
end
