# frozen_string_literal: true

module Licensee
  module Commands
    module Diff
    end
  end
end

RSpec.describe Licensee::Commands::Diff do
  let(:mit_fixture_path) { fixture_path('mit_markdown') }
  let(:license_file)     { File.join(mit_fixture_path, 'LICENSE.md') }

  def run_diff(*extra_args)
    Dir.chdir project_root do
      Open3.capture3(
        'bundle', 'exec', 'bin/licensee', 'diff', license_file,
        '--license=mit', *extra_args
      )
    end
  end

  def stdout(args = []) = run_diff(*args)[0]
  def status(args = []) = run_diff(*args)[2]

  context 'with default (word diff)' do
    it 'returns a zero exit code for an exact match' do
      _out, _err, s = run_diff
      expect(s.exitstatus).to be(0)
    end

    it 'outputs similarity information' do
      expect(stdout).to match(/Similarity/i)
    end
  end

  context 'with --line-diff' do
    it 'returns a zero exit code for an exact match' do
      _out, _err, s = run_diff('--line-diff')
      expect(s.exitstatus).to be(0)
    end

    it 'outputs similarity information' do
      expect(stdout(['--line-diff'])).to match(/Similarity/i)
    end
  end
end
