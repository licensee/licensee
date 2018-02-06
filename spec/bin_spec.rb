RSpec.describe 'command line invocation' do
  let(:command) { ['bundle', 'exec', 'bin/licensee'].push(subcommand) }
  let(:arguments) { [] }
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3(*[command, arguments].flatten)
    end
  end
  let(:parsed_output) { YAML.safe_load(stdout) }
  let(:stdout) { output[0] }
  let(:stderr) { output[1] }
  let(:status) { output[2] }
  let(:hash) { '46cdc03462b9af57968df67b450cc4372ac41f53' }

  context "detection" do
    let(:subcommand) { 'detect' }

    let(:expected) {
      {
        "License"       => "MIT License",
        "Matched files" => "LICENSE.md, licensee.gemspec",
        "LICENSE.md"    => {
          "Content hash" => hash,
          "Attribution"  => "Copyright (c) 2014-2017 Ben Balter",
          "Confidence"   => "100.00%",
          "Matcher"      => "Licensee::Matchers::Exact",
          "License"      => "MIT License"
        },
        "licensee.gemspec" => {
          "Confidence" => "90.00%",
          "Matcher"    => "Licensee::Matchers::Gemspec",
          "License"    => "MIT License"
        }
      }
    }

    {
      "No arguments" => [],
      "Project root" => [project_root],
      "License path" => [File.expand_path('LICENSE.md', project_root)]
    }.each do |name, args|
      context "When given #{name}" do
        let(:arguments) { args }

        it 'Returns a zero exit code' do
          expect(status.exitstatus).to eql(0)
        end

        it "returns the exected values" do
          hash = expected.dup

          if name == "License path"
            hash.delete("licensee.gemspec")
            hash["Matched files"] = "LICENSE.md"
          end

          expect(parsed_output).to eql(hash)
        end
      end
    end
  end

  context "version" do
    let(:subcommand) { 'version' }

    it "returns the version" do
      expect(stdout).to include(Licensee::VERSION)
    end

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to eql(0)
    end
  end

  context "license-path" do
    let(:subcommand) { 'license-path' }
    let(:arguments) { [project_root] }

    it "returns the license path" do
      expect(stdout).to match(File.join(project_root, "LICENSE.md"))
    end

    it 'Returns a zero exit code' do
      expect(status.exitstatus).to eql(0)
    end
  end
end
