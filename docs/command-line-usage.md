## Command line usage

This Gem includes an executable which can be used to detect and diff licenses.

To get a full list of available commands and options, run `licensee help`:

```
Licensee commands:
  licensee detect [PATH]        # Detect the license of the given project
  licensee diff [PATH]          # Compare the given license text to a known license
  licensee help [COMMAND]       # Describe available commands or one specific command
  licensee license-path [PATH]  # Returns the path to the given project's license file
  licensee version              # Return the Licensee version

Options:
  [--remote], [--no-remote]  # Assume PATH is a GitHub owner/repo path
```

### Detecting a project's license

This gem includes an executable which can be run using the `licensee detect [PATH]` command,
where `[PATH]` is:

* A directory, for example: `licensee detect vendor/gems/activesupport`
* A file, for example: `licensee detect LICENSE.txt`
* A GitHub repository, for example: `licensee detect https://github.com/facebook/react`

If you don't specify any arguments, `licensee detect` will just scan the current directory.

In all cases, you'll get an output that looks like:

```
License:        MIT License
Matched files:  LICENSE.md, licensee.gemspec
LICENSE.md:
  Content hash:  46cdc03462b9af57968df67b450cc4372ac41f53
  Attribution:   Copyright (c) 2014-2017 Ben Balter
  Confidence:    100.00%
  Matcher:       Licensee::Matchers::Exact
  License:       MIT License
licensee.gemspec:
  Confidence:  90.00%
  Matcher:     Licensee::Matchers::Gemspec
  License:     MIT License
```

Here are the available options:

```
Usage:
  licensee detect [PATH]

Options:
  [--json], [--no-json]          # Return output as JSON
  [--packages], [--no-packages]  # Detect licenses in package manager files
                                 # Default: true
  [--readme], [--no-readme]      # Detect licenses in README files
                                 # Default: true
  [--confidence=N]               # Confidence threshold
                                 # Default: 98
  [--license=LICENSE]            # The SPDX ID or key of the license to compare (implies --diff)
  [--diff], [--no-diff]          # Compare the license to the closest match
  [--remote], [--no-remote]      # Assume PATH is a GitHub owner/repo path
```

*Note: If you want to parse the command line output for use in another language or tool, it's highly recommended that you use the more stable `--json` output then attempting to parse the human-readable output.*

### Diff

You can also compare a given license to a known license.

```
Usage:
  licensee diff [PATH]

Options:
  [--license=LICENSE]        # The SPDX ID or key of the license to compare
  [--remote], [--no-remote]  # Assume PATH is a GitHub owner/repo path

Compare the given license text to a known license
```

### License Path

Licensee can return the path to a given project's license:

```
Usage:
  licensee license-path [PATH]

Options:
  [--remote], [--no-remote]  # Assume PATH is a GitHub owner/repo path

Returns the path to the given project's license file
```
