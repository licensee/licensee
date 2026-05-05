# frozen_string_literal: true

RSpec.describe Licensee::Projects::GitProject do
  let(:fixture) { 'mit' }

  describe '.available?' do
    it 'returns true when rugged is installed' do
      expect(described_class.available?).to be(true)
    end
  end

  context 'when rugged is not available' do
    before { allow(described_class).to receive(:available?).and_return(false) }

    it 'raises RuggedNotAvailable' do
      expect { described_class.new(fixture_path(fixture)) }.to raise_error(
        Licensee::Projects::GitProject::RuggedNotAvailable
      )
    end

    it 'RuggedNotAvailable is a kind of InvalidRepository' do
      expect(Licensee::Projects::GitProject::RuggedNotAvailable.ancestors).to include(
        Licensee::Projects::GitProject::InvalidRepository
      )
    end
  end

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
