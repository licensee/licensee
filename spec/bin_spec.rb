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
      expect(stdout).to match('750260c322080bab4c19fd55eb78bc73e1ae8f11')
    end

    it 'outputs the attribution' do
      expect(stdout).to match('2014-2016 Ben Balter')
    end

    it 'outputs the confidence' do
      expect(stdout).to match('Confidence: 100.00%')
    end

    it 'outputs the method' do
      expect(stdout).to match('Method: Licensee::Matchers::Exact')
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
