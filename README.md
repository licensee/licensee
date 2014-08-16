# Licensee

*A Ruby Gem to detect under what license a project is distributed.*

So you've got an open source project. How do you know under what terms the project is licensed? You could go in to the project folder, look for a file named `license.txt` (or something similar) and look for keywords like the license title. But what if the license doesn't have a title (like MIT)? What if the text of the license has been changed?

Licensee searches for a project's license file and then compares it to known licenses.

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
