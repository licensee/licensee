# Licensee

*A Ruby Gem to detect under what license a project is distributed.*

[![Build Status](https://travis-ci.org/benbalter/licensee.svg?branch=master)](https://travis-ci.org/benbalter/licensee) [![Gem Version](https://badge.fury.io/rb/licensee.svg)](http://badge.fury.io/rb/licensee) [![Coverage Status](https://coveralls.io/repos/github/benbalter/licensee/badge.svg?branch=rspec)](https://coveralls.io/github/benbalter/licensee?branch=rspec)

## The problem

* You've got an open source project. How do you know what you can and can't do with the software?
* You've got a bunch of open source projects, how do you know what their licenses are?
* You've got a project with a license file, but which license is it? Has it been modified?

## The solution

Licensee automates the process of reading `LICENSE` files and compares their contents to known licenses using a several strategies (which we call "Matchers"). It attempts to determine a project's license in the following order:

* If the license file has an explicit copyright notice, and nothing more (e.g., `Copyright (c) 2015 Ben Balter`), we'll assume the author intends to retain all rights, and thus the project isn't licensed.
* If the license is an exact match to a known license. If we strip away whitespace and copyright notice, we might get lucky, and direct string comparison in Ruby is cheap.
* If we still can't match the license, we use a fancy math thing called the [Sørensen–Dice coefficient](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient), which is really good at calculating the similarity between two strings. By calculating the percent changed from the known license to the license file, you can tell, e.g., that a given license is 95% similar to the MIT license, that 5% likely representing legally insignificant changes to the license text.

*Special thanks to [@vmg](https://github.com/vmg) for his Git and algorithmic prowess.*

## Installation

`gem install licensee` or add `gem 'licensee'` to your project's `Gemfile`.

## Documentation

See [the docs folder](/docs) for more information. You may be interested in:

* [Contributing to Licensee](CONTRIBUTING.md) (and development instructions)
* [Customizing Licensee's behavior](docs/customizing.md)
* [Instructions for using Licensee](docs/usage.md)
* More information about [what Licensee looks at](docs/what-we-look-at.md) (or doesn't, and why)

## Semantic Versioning

This project conforms to [semver](http://semver.org/). As a result of this policy, you can (and should) specify a dependency on this gem using the [Pessimistic Version Constraint](http://guides.rubygems.org/patterns/) with two digits of precision. For example:

spec.add_dependency 'licensee', '~> 1.0'

This means your project is compatible with licensee 1.0 up until 2.0. You can also set a higher minimum version:

spec.add_dependency 'licensee', '~> 1.1'
