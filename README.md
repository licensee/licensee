# Licensee

A Ruby Gem to detect under what license a project is distributed

So you've got an open source project. How do you know under what terms the project is licensed? You could go in to the project folder, look for a file named `license.txt` (or something similar) and look for keywords like the license title. But what if the license doesn't have a title (like MIT)? What if the text of the license has been changed?

Licensee searches for a project's license file and then compares it to known licenses.

## Prior Art

There are a handful of other approaches to this problem, the most notable being [LicenseFinder](https://github.com/pivotal/LicenseFinder). Most other projects focus on dependencies, package managers, or compliance.
