require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'shoulda'
require 'open3'
require_relative 'functions'
require_relative '../lib/licensee'

def assert_license_content(expected, readme)
  content = Licensee::Project::Readme.license_content(readme)
  assert_equal expected, content
end
