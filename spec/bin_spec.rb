RSpec.describe 'command line invocation' do
  let(:command) { ['ruby', 'bin/licensee'] }
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3(*[command, arguments].flatten)
    end
  end
  let(:stdout) { output[0] }
  let(:stderr) { output[1] }
  let(:status) { output[2] }

  context 'without any arguments' do
    let(:arguments) { [] }

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to eql(0)
    end

    it "detects the folder's license" do
      expect(stdout).to match('License: MIT License')
    end

    it 'outputs the hash' do
      expect(stdout).to match('d64f3bb4282a97b37454b5bb96a8a264a3363dc3')
    end

    it 'outputs the attribution' do
      expect(stdout).to match('2014-2016 Ben Balter')
    end

    it 'outputs the confidence' do
      expect(stdout).to match('Confidence: 100.00%')
      expect(stdout).to match('Confidence: 90.00%')
    end

    it 'outputs the method' do
      expect(stdout).to match('Matcher: Licensee::Matchers::Exact')
      expect(stdout).to match('Matcher: Licensee::Matchers::Gemspec')
    end

    it 'outputs the matched files' do
      expect(stdout).to include('Matched files: ["LICENSE.md", "licensee.gemspec"]')
    end
  end

  context 'when given a folder path' do
    let(:arguments) { [project_root] }

    it "detects the folder's license" do
      expect(stdout).to match('License: MIT License')
    end
  end

  context 'when given a license path' do
    let(:license_path) { File.expand_path 'LICENSE.md', project_root }
    let(:arguments) { [license_path] }

    it "detects the file's license" do
      expect(stdout).to match('License: MIT License')
    end
  end
end
