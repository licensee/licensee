require 'rake'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_licensee*.rb'
end

desc "Open console with Licensee loaded"
task :console do
  exec "pry -r ./lib/licensee.rb"
end
