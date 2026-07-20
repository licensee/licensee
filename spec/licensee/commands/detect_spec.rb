# frozen_string_literal: true

module Licensee
  module Commands
    module Detect
    end
  end
end

RSpec.describe Licensee::Commands::Detect do
  def command = ['bundle', 'exec', 'bin/licensee', 'detect']

  let(:arguments) { [] }
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3(*[command, arguments].flatten)
    end
  end

  let(:hash) { license_hashes['mit'] }
  let(:expected) do
    {
      'License'          => 'MIT',
      'Matched files'    => 'LICENSE.md, licensee.gemspec',
      'LICENSE.md'       => {
        'Content hash' => hash,
        'Attribution'  => 'Copyright (c) Ben Balter and Licensee contributors',
        'Confidence'   => '100.00%',
        'Matcher'      => 'Licensee::Matchers::Exact',
        'License'      => 'MIT'
      },
      'licensee.gemspec' => {
        'Confidence' => '90.00%',
        'Matcher'    => 'Licensee::Matchers::Gemspec',
        'License'    => 'MIT'
      }
    }
  end

  def stdout = output[0]
  def status = output[2]
  def parsed_output = YAML.safe_load(stdout)

  {
    'No arguments' => [],
    'Project root' => [project_root],
    'License path' => [File.expand_path('LICENSE.md', project_root)]
  }.each do |name, args|
    context "when given #{name}" do
      let(:arguments) { args }

      let(:expected_output) do
        expected.dup.tap do |hash|
          next unless name == 'License path'

          hash.delete('licensee.gemspec')
          hash['Matched files'] = 'LICENSE.md'
        end
      end

      it 'Returns a zero exit code' do
        expect(status.exitstatus).to be(0)
      end

      it 'returns the exected values' do
        expect(parsed_output).to eql(expected_output)
      end
    end
  end

  context 'with --json' do
    let(:arguments) { ['--json'] }
    let(:expected) { JSON.parse(fixture_contents('detect.json')).tap { |h| h['matched_files'][1].delete('content') } }

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to be(0)
    end

    it 'returns valid JSON' do
      expect { JSON.parse(stdout) }.not_to raise_error
    end

    it 'returns the expected output' do
      msg = +'`licensee detect --json` output did not match expectations. '
      msg << 'Run `script/dump-detect-json-fixture` and verify the output.'
      expect(JSON.parse(stdout).tap { |h| h['matched_files'][1].delete('content') }).to eql(expected), msg
    end
  end

  context 'with --diff' do
    let(:arguments) { ['--diff'] }

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to be(0)
    end

    it 'includes diff output' do
      expect(stdout).to include('Comparing to')
    end
  end

  context 'when printing closest non-matching licenses' do
    let(:tmpdir) { Dir.mktmpdir }
    let(:arguments) { ['--confidence', '0', tmpdir] }

    after { FileUtils.rm_rf(tmpdir) }

    def license_path = File.expand_path('LICENSE', tmpdir)

    before do
      license = Licensee::License.find('mit')
      File.write(license_path, "#{license.content}\n\nNOT PART OF THE LICENSE\n")
    end

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to be(0)
    end

    it 'prints closest non-matching licenses for non-exact matches' do
      closest = YAML.safe_load(stdout).dig('LICENSE', 'Closest non-matching licenses')
      expect(closest).to(satisfy { |value| value.is_a?(Hash) && !value.empty? })
    end
  end

  context 'when using the default command' do
    let(:command) { ['bundle', 'exec', 'bin/licensee'] }

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to be(0)
    end

    it 'returns the exected values' do
      expect(parsed_output).to eql(expected)
    end
  end

  context 'when using a non-existing command' do
    let(:command) { ['bundle', 'exec', 'bin/licensee', 'oops'] }

    it 'Returns a one exit code' do
      expect(status.exitstatus).to be(1)
    end
  end

  context 'when there is no license match' do
    let(:arguments) { ["#{project_root}/spec/fixtures/wrk-modified-apache"] }

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to be(0)
    end
  end

  context 'when directory is empty' do
    let(:tmpdir) { Dir.mktmpdir }
    let(:arguments) { [tmpdir] }

    after { FileUtils.rm_rf(tmpdir) }

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to be(0)
    end

    it 'returns empty matches' do
      expect(parsed_output).to eql({ 'License' => 'None' })
    end
  end

  context 'when given an unsupported remote host' do
    let(:arguments) { ['https://example.com/foo/bar'] }

    it 'Returns a one exit code' do
      expect(status.exitstatus).to be(1)
    end

    it 'prints an unsupported host message' do
      expect(output[1]).to include('Unsupported remote URL')
    end
  end

  context 'when using --recursive' do
    let(:fixtures_path) { File.expand_path('../../fixtures', __dir__) }

    context 'when scanning a directory with licensed subdirectories' do
      let(:arguments) { ['--recursive', fixtures_path] }

      it 'returns a zero exit code' do
        expect(status.exitstatus).to be(0)
      end

      it 'outputs at least one result' do
        expect(stdout).not_to be_empty
      end

      it 'outputs lines in path: LICENSE format' do
        expect(stdout.lines).to all(match(/\S+: \S+/))
      end
    end

    context 'when scanning an empty directory' do
      let(:arguments) { ['--recursive', tmpdir] }

      after { FileUtils.rm_rf(tmpdir) }

      def tmpdir
        @tmpdir ||= Dir.mktmpdir
      end

      it 'returns a non-zero exit code' do
        expect(status.exitstatus).to be(1)
      end

      it 'says no licenses detected' do
        expect(stdout).to include('No licenses detected')
      end
    end

    context 'when PATH itself has a license' do
      let(:arguments) { ['--recursive', File.join(fixtures_path, 'mit')] }

      it 'includes the root directory in output' do
        expect(stdout).to include('.')
      end

      it 'returns zero exit code' do
        expect(status.exitstatus).to be(0)
      end
    end

    context 'when using --json' do
      let(:arguments) { ['--recursive', '--json', fixtures_path] }

      it 'returns valid JSON array' do
        parsed = JSON.parse(stdout)
        expect(parsed).to be_an(Array)
      end

      it 'includes path keys in each result' do
        parsed = JSON.parse(stdout)
        expect(parsed.all? { |r| r.key?('path') }).to be true
      end
    end

    context 'when using --depth' do
      after { FileUtils.rm_rf(shallow_path) }

      def shallow_path
        @shallow_path ||= begin
          dir = Dir.mktmpdir
          subdir = File.join(dir, 'deep', 'nested', 'project')
          FileUtils.mkdir_p(subdir)
          FileUtils.cp(File.join(fixtures_path, 'mit', 'LICENSE.txt'), subdir)
          dir
        end
      end

      it 'with depth 1 does not find deeply nested licenses' do
        _, _, s = Open3.capture3(*[command, '--recursive', '--depth', '1', shallow_path].flatten,
                                 chdir: project_root)
        expect(s.exitstatus).to be(1)
      end

      it 'with depth 3 finds the nested license' do
        out, = Open3.capture3(*[command, '--recursive', '--depth', '3', shallow_path].flatten,
                              chdir: project_root)
        expect(out).to include('MIT')
      end
    end
  end
end
