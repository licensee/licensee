## What we look at

Licensee works by taking a detected license file, and comparing the contents to a short list of known licenses.

### Detecting the license file

Licensee uses [a series of regular expressions](https://github.com/licensee/licensee/blob/main/lib/licensee/project_files/license_file.rb#L6-L60) to score files in the project's root as potential license files. Here's a few examples of files that would be detected:

* `LICENSE`
* `LICENCE`
* `license.md`
* `COPYING.txt`
* `LICENSE-MIT`
* `COPYRIGHT`
* `UNLICENSE`

:warning: If the project has multiple license matches (e.g. a package file match, a file named license or similar that matches the regular expressions) that don't only match one well known license (see below), Licensee won't return a license for the project, but all matches are returned in the licenses array.

### `LICENSES/` directory

Licensee also scans the top-level `LICENSES/` directory, which is used by projects following the [REUSE specification](https://reuse.software/). In a REUSE-compliant layout, each license in use is stored as a separate file named after its SPDX identifier, for example:

* `LICENSES/MIT.txt`
* `LICENSES/Apache-2.0.txt`
* `LICENSES/GPL-2.0-only.txt`
* `LICENSES/LicenseRef-custom.txt`

Files in `LICENSES/` are scored separately from files in the project root: the filename must match a valid SPDX license identifier (or a `LicenseRef-` custom identifier) and must have a standard text-ish extension (`.txt`, `.md`, `.markdown`, or `.html`). Any file in `LICENSES/` that meets these criteria is treated as a candidate license file with the highest possible filename score.

### Known licenses

Licensee relies on the crowdsourced license content and metadata from [`choosealicense.com`](https://choosealicense.com).

### What it doesn't look at by default

* The licensing of a project's dependencies
* References to licenses in `README`, `README.md`, etc.
* Every single possible license (just the most popular ones)
* Compliance - [multiple tools](https://github.com/todogroup/awesome-oss-mgmt#licensing) and human review are needed to address all aspects

### Huh? Why don't you look at X by default?

Because reasons.

#### Why not just look at the "license" field of [insert package manager here]?

The LICENSE file is platform-agnostic, and most popular licenses today *require* that the license itself be distributed along side the software. Simply putting the letters "MIT" or "GPL" in a configuration file doesn't really meet that requirement. Those files are designed to be read by computers (who can't enter into contracts), not humans (who can).

From a practical standpoint, every language has its own package manager (some even have multiple). That means that if you want to detect the license of an arbitrary project, you'll have to implement [100s](https://github.com/github/linguist/tree/master/samples) of package-manager-specific detection strategies.

However, licensee does [optionally](https://github.com/licensee/licensee/blob/main/docs/customizing.md) look at license metadata of a [handful](https://github.com/licensee/licensee/blob/main/lib/licensee/project_files/package_manager_file.rb) of package manager files.

License metadata in package manager files can complement detection from `LICENSE` files through [license expressions](https://spdx.org/spdx-specification-21-web-version#h.jxpfx0ykyb60) (e.g., is a `GPL-3.0` license `-only` or `or-later-versions`, or do multiple `LICENSE` files indicate disjunctive choice) but licensee currently does not parse these expressions.

#### What about looking to see if the author said something in the readme?

There are lots of ways of saying a project or some portion of it is under a license in natural language, and that's what is often found in a `README` file. Licensee can't reliably parse natural language.

However, licensee does [optionally](https://github.com/licensee/licensee/blob/main/docs/customizing.md) look for license indicators in `README` files. Just don't expect that it will detect most statements found in such files, and expect to review any that it finds.

#### What about checking every single file for a copyright header?

It's a lot of work, as there's no standardized, cross-platform way to describe a _project's_ license within a source file comment. (Adding a [SPDX License Idenfifier](https://spdx.org/using-spdx-license-identifier) to source code comments can clarify what license applies to a single source file, but licensee reports on licenses at a project level.)

Scanning every source file for potential legal notices is a useful part of a license compliance program, but there are [other tools](https://github.com/todogroup/awesome-oss-mgmt#licensing) that specialize in that.
