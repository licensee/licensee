# frozen_string_literal: true

module Licensee
  module Commands
    module Version
    end
  end
end

RSpec.describe Licensee::Commands::Version do
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3('bundle', 'exec', 'bin/licensee', 'version')
    end
  end

  def stdout = output[0]
  def status = output[2]

  it 'returns the version' do
    expect(stdout).to include(Licensee::VERSION)
  end

  it 'Returns a zero exit code' do
    expect(status.exitstatus).to be(0)
  end
end
