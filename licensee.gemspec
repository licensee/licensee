require File.expand_path("../lib/licensee/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'licensee'
  gem.version = Licensee::VERSION
  gem.date    = Date.today.to_s

  gem.summary = "A Ruby Gem to detect under what license a project is distributed"
  gem.description = "Licensee automates the process of reading LICENSE files (and optionally readme files too) and compares their contents to known licenses using a fancy math thing called the Levenshtein Distance."

  gem.authors  = ['Ben Balter']
  gem.email    = 'ben.balter@github.com'
  gem.homepage = 'http://github.com/benbalter/licensee'

  gem.add_dependency('levenshtein-ffi', '~> 1.1')
  gem.add_dependency('diffy', '~> 3.0')
  gem.add_development_dependency('pry', '~> 0.9')
  gem.add_development_dependency('shoulda', '~> 3.5')
  gem.add_development_dependency('rake', '~> 10.3')

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end
