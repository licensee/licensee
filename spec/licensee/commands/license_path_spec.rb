# frozen_string_literal: true

module Licensee
  module Commands
    module LicensePath
    end
  end
end

RSpec.describe Licensee::Commands::LicensePath do
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3('bundle', 'exec', 'bin/licensee', 'license-path', project_path)
    end
  end

  def project_path = fixture_path('mit_markdown')
  def stdout = output[0]
  def status = output[2]

  it 'returns the license path' do
    expect(stdout).to match(File.join(project_path, 'LICENSE.md'))
  end

  it 'Returns a zero exit code' do
    expect(status.exitstatus).to be(0)
  end
end
