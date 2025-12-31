# frozen_string_literal: true

RSpec.describe Licensee::Projects::GitProject do
  let(:fixture) { 'mit' }

  context 'when a new git repo is handled as a file system project' do
    let(:path) { fixture_path(fixture) }

    before do
      Dir.chdir path do
        `git init`
      end
    end

    after do
      FileUtils.rm_rf File.expand_path '.git', path
    end

    it 'raises InvalidRepository error' do
      expect { described_class.new(path) }.to raise_error(ArgumentError)
    end
  end
end
