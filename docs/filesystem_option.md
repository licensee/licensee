# Filesystem Option

When running Licensee on a local Git repository, it uses Git to retrieve the committed file content by default. This means that uncommitted changes to license files will not be detected until they are committed. 

## Usage

To force Licensee to use the filesystem contents (including uncommitted changes) instead of Git data, use the `--filesystem` option:

```bash
licensee detect --filesystem PATH
```

## Example

Consider a scenario where you have a Git repository with a committed MIT license, but you've made changes to the LICENSE file to switch to Apache-2.0 without committing:

```bash
# Without --filesystem: Shows the committed MIT license
licensee detect /path/to/repo

# With --filesystem: Shows the Apache-2.0 license from the current file content
licensee detect --filesystem /path/to/repo
```

## When to use

The `--filesystem` option is most useful in the following scenarios:

1. When you want to check license changes before committing them
2. When working with non-Git repositories that happen to be within a Git directory
3. When you need to detect licenses in files that have been modified but not yet committed

By default, Licensee will detect if the path is not a valid Git repository and automatically use filesystem detection instead. The `--filesystem` option lets you force this behavior even when in a Git repository.