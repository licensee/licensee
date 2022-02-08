## Customizing Licensee's behavior

### Adjusting the confidence threshold

If you'd like, you can make Licensee less stringent in its comparison, but risk getting false positives as a result. The confidence threshold is an integer between 1 and 100, with the default being 98, meaning that License is at least 98% confident that the file represents the matched license.

```ruby
LICENSEE.confidence_threshold
=> 98

LICENSEE.confidence_threshold = 90
=> 90
```

### Matching package manager metadata

Licensee supports the ability to take into account Ruby, Node and CRAN package manager metadata, disabled by default. [There are reasons you may not want to use this metadata](what-we-look-at.md). You can explicitly instruct licensee to take this information into account as follows:

```ruby
project = Licensee.project("path/to/project", detect_packages: true)
project.license
=> #<Licensee::Licensee key="mit">
```

**Note:** The package manager metadata matchers have a confidence of 90%, so you must set the confidence_threshold to 90 or lower for them to work.

### Matching project README license references

Licensee supports the ability to take into account human readable references to licenses within the project's README, disabled by default. [There are reasons you may not want to use this](what-we-look-at.md). You can explicitly instruct licensee to take this information into account as follows:

```ruby
project = Licensee.project("path/to/project", detect_readme: true)
project.license
=> #<Licensee::Licensee key="mit">
```

**Note:** The README license reference matchers have a confidence of 90%, so you must set the confidence_threshold to 90 or lower for them to work.
