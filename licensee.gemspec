# frozen_string_literal: true

require File.expand_path('lib/licensee/version', __dir__)

Gem::Specification.new do |gem|
  gem.name    = 'licensee'
  gem.version = Licensee::VERSION

  gem.summary = 'A Ruby Gem to detect open source project licenses'
  gem.description = <<-DESC
    Licensee automates the process of reading LICENSE files and
    compares their contents to known licenses using a fancy maths.
  DESC

  gem.authors  = ['Ben Balter']
  gem.email    = 'ben.balter@github.com'
  gem.homepage = 'https://github.com/benbalter/licensee'
  gem.license  = 'MIT'

  gem.bindir = 'bin'
  gem.executables << 'licensee'

  gem.add_dependency('dotenv', '~> 2.0')
  gem.add_dependency('octokit', '~> 4.8.0')
  gem.add_dependency('reverse_markdown', '~> 1.0')
  gem.add_dependency('rugged', '~> 0.24')
  gem.add_dependency('thor', '~> 0.19')

  gem.add_development_dependency('mustache', '>= 0.9', '< 2.0')
  gem.add_development_dependency('pry', '~> 0.9')
  gem.add_development_dependency('rake', '~> 10.3')
  gem.add_development_dependency('rspec', '~> 3.5')
  gem.add_development_dependency('rubocop', '~> 0.49')
  gem.add_development_dependency('simplecov', '~> 0.16')
  gem.add_development_dependency('webmock', '~> 3.1')

  gem.required_ruby_version = '> 2.3'

  # ensure the gem is built out of versioned files
  gem.files = Dir[
    'Rakefile',
    '{bin,lib,man,test,vendor,spec}/**/*',
    'README*', 'LICENSE*'
  ] & `git ls-files -z`.split("\0")
end
