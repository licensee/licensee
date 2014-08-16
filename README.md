# Licensee

*A Ruby Gem to detect under what license a project is distributed.*

## The problem

* You've got an open source project. How do you know what you can and can't do with the software?
* You've got a bunch of open source projects, how do you know what their licenses are?
* You've got a project with a license file, but which license is it? Has it been modified?

## The solution

Licensee automates the process of reading `LICENSE` files (and optionally readme files too) and compares their contents to known licenses using a fancy math thing called the [Levenshtein Distance](http://en.wikipedia.org/wiki/Levenshtein_distance).

By calculating the percent changed from the known license, you can tell, e.g., that a given license is 98% similar to the MIT license, that 2% likely representing the copyright line being properly adapted to the project.

## Usage

```ruby
license = Licensee.license "/path/to/a/project"
=> #<Licensee::License name="MIT" match=0.9842154131847726>

p.meta["title"]
=> "MIT License"

p.meta["source"]
=> "http://opensource.org/licenses/MIT"

p.meta["description"]
=> "A permissive license that is short and to the point. It lets people do anything with your code with proper attribution and without warranty."

p.meta["permitted"]
=> ["commercial-use","modifications","distribution","sublicense","private-use"]
```

## What it looks at

* `LICENSE`, `LICENSE.txt`, etc. files in the root of the project, comparing the body to known licenses
* `README`, `README.md`, etc. files in the root of the project, comparing links to known license sources
* Crowdsourced license content and metadata from [`choosealicense.com`](http://choosealicense.com)

## What it doesn't look at

* Dependency licensing
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

Clearly checking the actual text into version control is definitive. Looking to a readme isn't great, but it's a popular convention, and easy enough to check if you want, so that's what this project does.

## Strict mode

When no license file is found, Licensee will also look to Readmes for references to a license, a common shorthand convention. To disable this behavior, simply set `Licensee::STRICT = true`.
