# Licensee

*A Ruby Gem to detect under what license a project is distributed.*

[![Build Status](https://travis-ci.org/licensee/licensee.svg?branch=master)](https://travis-ci.org/licensee/licensee) [![Gem Version](https://badge.fury.io/rb/licensee.svg)](http://badge.fury.io/rb/licensee) [![Maintainability](https://api.codeclimate.com/v1/badges/5dca6a1ff7015c6d8cab/maintainability)](https://codeclimate.com/github/benbalter/licensee/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/5dca6a1ff7015c6d8cab/test_coverage)](https://codeclimate.com/github/benbalter/licensee/test_coverage) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) 


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

To use the latest released [gem](https://rubygems.org/pages/download) from [RubyGems](https://rubygems.org/):

    gem install licensee

To use licensee programmatically in your own Ruby project, add `gem 'licensee'` to your project's `Gemfile`.

To run licensee directly from source:

    gem install bundler
    bundle install --path vendor/bundle
    bundle exec bin/licensee

On Windows, the last line needs to include the Ruby interpreter:

    bundle exec ruby bin\licensee

In a Docker Debian Stretch container, minimum dependencies are:

```
apt-get install -y ruby bundler cmake pkg-config git libssl-dev
```

## Documentation

See [the docs folder](/docs) for more information. You may be interested in:

* [Instructions for using Licensee](usage.md)
* [Customizing Licensee's behavior](customizing.md)
* [Contributing to Licensee](CONTRIBUTING.md) (and development instructions)
* More information about [what Licensee looks at](what-we-look-at.md) (or doesn't, and why)

## Semantic Versioning

This project conforms to [semver](http://semver.org/). As a result of this policy, you can (and should) specify a dependency on this gem using the [Pessimistic Version Constraint](http://guides.rubygems.org/patterns/) with two digits of precision. For example:

```ruby
spec.add_dependency 'licensee', '~> 1.0'
```

This means your project is compatible with licensee 1.0 up until 2.0. You can also set a higher minimum version:

```ruby
spec.add_dependency 'licensee', '~> 1.1'
```
