require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'shoulda'
require 'open3'
require_relative 'functions'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'licensee'
