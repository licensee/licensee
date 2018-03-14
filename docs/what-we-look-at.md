## What we look at

Licensee works by taking a detected license file, and comparing the contents to a short list of known licenses.

### Detecting the license file

Licensee uses [a series of regular expressions](https://github.com/benbalter/licensee/blob/master/lib/licensee/project_files/license_file.rb#L6-L43) to score files in the project's root as potential license files. Here's a few examples of files that would be detected:

* `LICENSE`
* `LICENCE`
* `license.md`
* `COPYING.txt`
* `LICENSE-MIT`
* `COPYRIGHT`
* `UNLICENSE`

If the project has multiple license files or a file named `license` or similar (as defined by the regular expressions linked above) that doesn't contain a only one well known license (see below) in its standard form, chances are Licensee won't detect the project's license.

### Known licenses

Licensee relies on the crowdsourced license content and metadata from [`choosealicense.com`](http://choosealicense.com).

### What it doesn't look at

* The licensing of a project's dependencies
* References to licenses in `README`, `README.md`, etc.
* Every single possible license (just the most popular ones)
* Compliance - If you're looking for this, take a look at [LicenseFinder](https://github.com/pivotal/LicenseFinder).

### Huh? Why don't you look at X?

Because reasons.

#### Why not just look at the "license" field of [insert package manager here]?

Because it's not legally binding. A license is a legal contract. You give up certain rights (e.g., the right to sue the author) in exchange for the right to use the software.

Most popular licenses today *require* that the license itself be distributed along side the software. Simply putting the letters "MIT" or "GPL" in a configuration file doesn't really meet that requirement. Those files are designed to be read by computers (who can't enter into contracts), not humans (who can). It's great metadata, but that's about it.

From a practical standpoint, every language has its own package manager (some even have multiple). That means that if you want to detect the license of an arbitrary project, you'll have to implement [100s](https://github.com/github/linguist/tree/master/samples) of package-manager-specific detection strategies. The LICENSE file is a platform-agnostic and a better indicator, although it does not clarify some things, like whether you are using GPL-3.0-only or GPL-3.0-or-later.

#### What about looking to see if the author said something in the readme?

You could make an argument that, when linked or sufficiently identified, the terms of the license are incorporated by reference, or at least that the author's intent is there. There's a handful of reasons why this isn't ideal. For one, if you're using the MIT or BSD (ISC) license, along with a few others, there's templematic language, like the copyright notice, which would go unfilled.

#### What about checking every single file for a copyright header?

It's a lot of work, as there's no standardized, cross-platform way to describe a project's license within a comment.

Checking the actual text into version control is mostly definitive, with GNU licenses as a notable exception, so that's what this project looks at.
