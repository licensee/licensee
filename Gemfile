# frozen_string_literal: true

source 'https://rubygems.org'

faraday_version = ENV.fetch('FARADAY_VERSION', '~> 2.0')

gem 'faraday', faraday_version

gem 'faraday-retry' if faraday_version.start_with?('~> 2')

gemspec

gem.add_development_dependency('gem-release', '~> 2.0')
gem.add_development_dependency('mustache', '>= 0.9', '< 2.0')
gem.add_development_dependency('pry', '~> 0.9')
gem.add_development_dependency('rspec', '~> 3.5')
gem.add_development_dependency('rubocop', '~> 1.0')
gem.add_development_dependency('rubocop-performance', '~> 1.5')
gem.add_development_dependency('rubocop-rspec', '~> 2.0')
gem.add_development_dependency('simplecov', '~> 0.16')
gem.add_development_dependency('webmock', '~> 3.1')