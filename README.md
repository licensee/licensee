# Licensee
_A Ruby Gem to detect under what license a project is distributed._

[![Build Status](https://travis-ci.org/benbalter/licensee.svg?branch=master)](https://travis-ci.org/benbalter/licensee) [![Gem Version](https://badge.fury.io/rb/licensee.svg)](http://badge.fury.io/rb/licensee)

## The problem
- You've got an open source project. How do you know what you can and can't do with the software?
- You've got a bunch of open source projects, how do you know what their licenses are?
- You've got a project with a license file, but which license is it? Has it been modified?

## The solution
Licensee automates the process of reading `LICENSE` files and compares their contents to known licenses using a several strategies (which we call "Matchers"). It attempts to determine a project's license in the following order:
- If the license file has an explicit copyright notice, and nothing more (e.g., `Copyright (c) 2015 Ben Balter`), we'll assume the author intends to retain all rights, and thus the project isn't licensed.
- If the license is an exact match to a known license. If we strip away whitespace and copyright notice, we might get lucky, and direct string comparison in Ruby is cheap.
- If we still can't match the license, we use a fancy math thing called the [Sørensen–Dice coefficient](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient), which is really good at calculating the similarity between two strings. By calculating the percent changed from the known license to the license file, you can tell, e.g., that a given license is 90% similar to the MIT license, that 10% likely representing the copyright line being properly adapted to the project.

_Special thanks to [@vmg](https://github.com/vmg) for his Git and algorithmic prowess._

## Installation
`gem install licensee` or add `gem 'licensee'` to your project's `Gemfile`.

## Usage

```ruby
license = Licensee.license "/path/to/a/project"
=> #<Licensee::License name="MIT" match=0.9842154131847726>

license.key
=> "mit"

license.name
=> "MIT License"

license.meta["source"]
=> "http://opensource.org/licenses/MIT"

license.meta["description"]
=> "A permissive license that is short and to the point. It lets people do anything with your code with proper attribution and without warranty."

license.meta["permitted"]
=> ["commercial-use","modifications","distribution","sublicense","private-use"]
```

## Command line usage
1. `cd` into a project directory
2. execute the `licensee` command

You'll get an output that looks like:

```
License: MIT
Confidence: 98.42%
Matcher: Licensee::GitMatcher
```

## What it looks at
- `LICENSE`, `LICENSE.txt`, `COPYING`, etc. files in the root of the project, comparing the body to known licenses
- Crowdsourced license content and metadata from [`choosealicense.com`](http://choosealicense.com)

## What it doesn't look at
- Dependency licensing
- References to licenses in `README`, `README.md`, etc.
- Every single possible license (just the most popular ones)
- Compliance (e.g., whitelisting certain licenses)

If you're looking for dependency license checking and compliance, take a look at [LicenseFinder](https://github.com/pivotal/LicenseFinder).

## Huh? Why don't you look at X?
Because reasons.

### Why not just look at the "license" field of [insert package manager here]?
Because it's not legally binding. A license is a legal contract. You give up certain rights (e.g., the right to sue the author) in exchange for the right to use the software.

Most popular licenses today _require_ that the license itself be distributed along side the software. Simply putting the letters "MIT" or "GPL" in a configuration file doesn't really meet that requirement.

Not to mention, it doesn't tell you much about your rights as a user. Is it GPLv2? GPLv2 or later? Those files are designed to be read by computers (who can't enter into contracts), not humans (who can). It's great metadata, but that's about it.

### What about looking to see if the author said something in the readme?
You could make an argument that, when linked or sufficiently identified, the terms of the license are incorporated by reference, or at least that the author's intent is there. There's a handful of reasons why this isn't ideal. For one, if you're using the MIT or BSD (ISC) license, along with a few others, there's templematic language, like the copyright notice, which would go unfilled.

### What about checking every single file for a copyright header?
Because that's silly in the context of how software is developed today. You wouldn't put a copyright notice on each page of a book. Besides, it's a lot of work, as there's no standardized, cross-platform way to describe a project's license within a comment.

Checking the actual text into version control is definitive, so that's what this project looks at.

## Bootstrapping a local development environment
`script/bootstrap`

## Running tests
`script/cibuild`

## Updating the licenses
License data is pulled from `choosealicense.com`. To update the license data, simple run `script/vendor-licenses`.

## Roadmap
See [proposed enhancements](https://github.com/benbalter/licensee/labels/enhancement).
