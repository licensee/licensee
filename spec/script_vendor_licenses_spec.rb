# frozen_string_literal: true

RSpec.describe 'script/vendor-licenses' do
  let(:script_path) { File.expand_path('../script/vendor-licenses', project_root) }
  let(:vendor_data_dir) { File.expand_path('vendor/choosealicense.com/_data', project_root) }
  let(:vendor_licenses_dir) { File.expand_path('vendor/choosealicense.com/_licenses', project_root) }

  it 'passes a POSIX sh syntax check' do
    _, stderr, status = Open3.capture3('sh', '-n', script_path)
    expect(status.exitstatus).to be(0), "sh -n failed: #{stderr}"
  end

  it 'does not contain Bash-specific syntax' do
    content = File.read(script_path)
    expect(content).not_to match(/\[\[/)
  end

  it 'uses --no-wildcards-match-slash for GNU tar' do
    content = File.read(script_path)
    expect(content).to include('--no-wildcards-match-slash')
  end

  it 'does not vendor nested _data/i18n files' do
    nested = Dir["#{vendor_data_dir}/i18n/**/*.yml"]
    expect(nested).to be_empty, "Unexpected nested i18n files found: #{nested.join(', ')}"
  end

  it 'vendors top-level _data YAML files' do
    top_level = Dir["#{vendor_data_dir}/*.yml"]
    expect(top_level).not_to be_empty
  end

  it 'vendors _licenses files' do
    expect(Dir["#{vendor_licenses_dir}/*"]).not_to be_empty
  end
end
