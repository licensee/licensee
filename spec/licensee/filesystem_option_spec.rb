# frozen_string_literal: true

RSpec.describe 'Filesystem option' do
  let(:mit_license) { Licensee::License.find('mit') }
  let(:apache_license) { Licensee::License.find('apache-2.0') }
  let(:project_path) { Dir.mktmpdir }
  let(:license_path) { File.expand_path('LICENSE', project_path) }

  before do
    # Create MIT license
    File.write(license_path, mit_license.content)
    
    # Initialize git and commit the MIT license
    `cd #{project_path} && git init && git add LICENSE && git config user.name "Test User" && git config user.email "test@example.com" && git commit -m "Add MIT license"`

    # Change the file to Apache (uncommitted)
    File.write(license_path, apache_license.content)
  end

  after { FileUtils.rm_rf(project_path) }

  context 'without filesystem option' do
    let(:project) { Licensee.project(project_path) }

    it 'detects the committed MIT license from git' do
      expect(project.license).to eql(mit_license)
    end
  end

  context 'with filesystem option' do
    let(:project) { Licensee.project(project_path, filesystem: true) }

    it 'detects the uncommitted Apache license from filesystem' do
      expect(project.license).to eql(apache_license)
    end
  end
end