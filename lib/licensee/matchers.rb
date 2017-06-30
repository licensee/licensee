module Licensee
  module Matchers
    autoload :Cabal, 'licensee/matchers/cabal_matcher'
    autoload :Copyright, 'licensee/matchers/copyright_matcher'
    autoload :Cran, 'licensee/matchers/cran_matcher'
    autoload :Dice, 'licensee/matchers/dice_matcher'
    autoload :DistZilla, 'licensee/matchers/dist_zilla_matcher'
    autoload :Exact, 'licensee/matchers/exact_matcher'
    autoload :Gemspec, 'licensee/matchers/gemspec_matcher'
    autoload :NpmBower, 'licensee/matchers/npm_bower_matcher'
    autoload :Package, 'licensee/matchers/package_matcher'
  end
end
