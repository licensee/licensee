# frozen_string_literal: true

RSpec.describe Licensee::ConfigFile do
  subject(:config_file) { described_class.new(content, file) }

  let(:filename) { 'license.txt' }
  let(:file) { { name: filename } }
  let(:config) do
    {
      'ignore' => [
        'licensee.gemspec',
        'script/detect-license.sh'
      ]
    }
  end
  let(:content) { Psych.dump(config) }

  let(:config_file_path) { '.licensee.yml' }

  it 'stores the content' do
    expect(config_file.content).to eql(content)
  end

  it 'parses the config' do
    expect(config_file.config).to eql(config)
  end

  it 'detects ignore files' do
    expect(described_class.name_score(config_file_path)).to be(1)
  end

  context 'with a non-matching filename' do
    let(:filename) { 'foo.txt' }

    it 'does not match other files' do
      expect(described_class.name_score(filename)).to be(0)
    end
  end

  it 'parses paths' do
    expect(config_file.ignored_paths).to eql(['licensee.gemspec', 'script/detect-license.sh', '.licensee.yml'])
  end

  context 'with an ignored file' do
    let(:filename) { 'licensee.gemspec' }

    it 'is ignored' do
      expect(config_file.ignored?(file)).to be true
    end
  end

  context 'with an ignored file in a subdirectory' do
    let(:filename) { 'script/detect-license.sh' }

    it 'is ignored' do
      expect(config_file.ignored?(file)).to be true
    end
  end

  context 'with a non-ignored file' do
    let(:filename) { 'LICENSE.txt' }

    it 'is ignored' do
      expect(config_file.ignored?(file)).to be false
    end
  end

  context 'with a glob pattern' do
    let(:config) do
      {
        'ignore' => ['*.txt']
      }
    end
    let(:filename) { 'LICENSE.txt' }

    it 'is ignored' do
      expect(config_file.ignored?(file)).to be true
    end
  end

  context 'with invalid YAML' do
    let(:content) { "foo: bar, {{ baz }}:\n" }

    it 'return nil for config' do
      expect(config_file.config).to be_nil
    end
  end
end
