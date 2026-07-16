# frozen_string_literal: true

module Licensee
  module Commands
    module Scan
    end
  end
end

RSpec.describe Licensee::Commands::Scan do
  def command = ['bundle', 'exec', 'bin/licensee', 'scan']

  let(:fixtures_path) { File.expand_path('../../fixtures', __dir__) }
  let(:arguments) { [] }
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3(*[command, arguments].flatten)
    end
  end

  def stdout = output[0]
  def stderr = output[1]
  def status = output[2]

  context 'when scanning a directory with licensed subdirectories' do
    let(:arguments) { [fixtures_path] }

    it 'returns a zero exit code' do
      expect(status.exitstatus).to be(0)
    end

    it 'outputs at least one subdirectory with a detected license' do
      expect(stdout).not_to be_empty
    end

    it 'does not say "No licenses detected"' do
      expect(stdout).not_to include('No licenses detected')
    end

    it 'outputs paths relative to the scanned directory' do
      expect(stdout.lines).to all(match(/\S+: \S+/))
    end
  end

  context 'when scanning an empty directory' do
    let(:tmpdir) { Dir.mktmpdir }
    let(:arguments) { [tmpdir] }

    after { FileUtils.rm_rf(tmpdir) }

    it 'returns a non-zero exit code' do
      expect(status.exitstatus).to be(1)
    end

    it 'says no licenses detected' do
      expect(stdout).to include('No licenses detected')
    end
  end

  context 'when no path is given' do
    it 'uses the current directory and does not error' do
      expect(status.exitstatus).to be_a(Integer)
    end
  end

  context 'when using --json flag' do
    let(:arguments) { ['--json', fixtures_path] }

    it 'returns valid JSON' do
      parsed = JSON.parse(stdout)
      expect(parsed).to be_an(Array)
    end

    it 'includes path keys in each result' do
      parsed = JSON.parse(stdout)
      expect(parsed.all? { |r| r.key?('path') }).to be true
    end
  end

  context 'when using --depth option' do
    let(:shallow_path) do
      dir = Dir.mktmpdir
      subdir = File.join(dir, 'deep', 'nested', 'project')
      FileUtils.mkdir_p(subdir)
      FileUtils.cp(File.join(fixtures_path, 'mit', 'LICENSE.txt'), subdir)
      dir
    end

    after { FileUtils.rm_rf(shallow_path) }

    it 'with depth 1 does not find deeply nested licenses' do
      _, _, status = Open3.capture3(*[command, '--depth', '1', shallow_path].flatten,
                                    chdir: project_root)
      # depth=1 only checks immediate children; deep/nested/project is 3 levels deep
      expect(status.exitstatus).to be(1)
    end

    it 'with depth 3 finds the nested license' do
      out, = Open3.capture3(*[command, '--depth', '3', shallow_path].flatten,
                            chdir: project_root)
      expect(out).to include('MIT')
    end

    it 'with depth 3 returns zero exit code for nested license' do
      _, _, status = Open3.capture3(*[command, '--depth', '3', shallow_path].flatten,
                                    chdir: project_root)
      expect(status.exitstatus).to be(0)
    end
  end
end
