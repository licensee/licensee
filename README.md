# Licensee

*A Ruby Gem to detect under what license a project is distributed.*

[![Build Status](https://travis-ci.org/benbalter/licensee.svg)](https://travis-ci.org/benbalter/licensee) [![Gem Version](https://badge.fury.io/rb/licensee.svg)](http://badge.fury.io/rb/licensee)

## The problem

* You've got an open source project. How do you know what you can and can't do with the software?
* You've got a bunch of open source projects, how do you know what their licenses are?
* You've got a project with a license file, but which license is it? Has it been modified?

## The solution

Licensee automates the process of reading `LICENSE` files and compares their contents to known licenses using a several strategies (which we call "Matchers":

First, we look to see if the license is an exact match. Licenses like GPL don't have a copyright notice that needs to be changed in the license itself, so if we strip away whitespace, we might get lucky, and direct string comparison is cheap.

Next, we look to Git's internal change calculation method, which is fast, but is done on a line-by-line basis, so if the license is wrapped differently, or has extra words inserted, it's not going to match the license.

Finally, if we still can't match the license, we use a fancy math thing called the [Levenshtein distance algorithm](https://en.wikipedia.org/wiki/Levenshtein_distance), which while slow, is really good at calculating the similarity between two a known license and an unknown license. By calculating the percent changed from the known license, you can tell, e.g., that a given license is 98% similar to the MIT license, that 2% likely representing the copyright line being properly adapted to the project.

Licensee will even diff the distributed license with the original, so you can see exactly what, if anything's been changed.

*Special thanks to [@vmg](https://github.com/vmg) for his Git prowess.*

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

## Diffing

You can also generate a diff of the known license to the distributed license.

```ruby
puts Licensee.diff "/path/to/a/project"
-Copyright (c) [year] [fullname]
+Copyright (c) 2014 Ben Balter
```

For a full list of diff options (HTML output, color output, etc.) see [Diffy](https://github.com/samg/diffy).

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

* `LICENSE`, `LICENSE.txt`, etc. files in the root of the project, comparing the body to known licenses
* Crowdsourced license content and metadata from [`choosealicense.com`](http://choosealicense.com)

## What it doesn't look at

* Dependency licensing
* References to licenses in `README`, `README.md`, etc.
* Structured license data in package manager configuration files (like Gemfiles)
* Every single possible license (just the most popular ones)
* Compliance (e.g., whitelisting certain licenses)

If you're looking for dependency license checking and compliance, take a look at [LicenseFinder](https://github.com/pivotal/LicenseFinder).

## Huh? Why don't you look at X?

Because reasons.

### Why not just look at the "license" field of [insert package manager here]?

Because it's not legally binding. A license is a legal contract. You give up certain rights (e.g., the right to sue the author) in exchange for the right to use the software.

Most popular licenses today *require* that the license itself be distributed along side the software. Simply putting the letters "MIT" or "GPL" in a configuration file doesn't really meet that requirement.

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

License data is pulled from `choosealicense.com`. To update the license data, simple run `bower update`.

## Roadmap

See [proposed enhancements](https://github.com/benbalter/licensee/labels/enhancement).
