# frozen_string_literal: true

source 'https://rubygems.org'

faraday_version = ENV.fetch('FARADAY_VERSION', '~> 2.0')

gem 'faraday', faraday_version

gem 'faraday-retry' if faraday_version.start_with?('~> 2')

gemspec
