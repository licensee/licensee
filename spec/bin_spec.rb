# frozen_string_literal: true

module Bin
end

RSpec.describe Bin do
  let(:output) do
    Dir.chdir project_root do
      Open3.capture3('bundle', 'exec', 'bin/licensee', 'help')
    end
  end

  def stdout = output[0]
  def status = output[2]

  it 'Returns a zero exit code' do
    expect(status.exitstatus).to be(0)
  end

  it 'returns the help text' do
    expect(stdout).to include('Licensee commands:')
  end
end
