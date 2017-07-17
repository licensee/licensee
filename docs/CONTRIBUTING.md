# Contributing to Licensee

Interested in contributing to Licensee? We’d love your help. Licensee is an open source project, built one contribution at a time by users like you.

## Reporting an improperly detected license

Licensee is an open source project used by hosted services like GitHub and GitLab which often  detect licenses using prior versions of Licensee and cache the result.

If you'd like to report that a license is improperly detected by a hosted service, please contact [GitHub support](https://github.com/contact) or [GitLab support](https://about.gitlab.com/getting-help/) directly.

To check if Licensee itself can properly detect a license, please:

1. Clone the repository locally `git clone https://github.com/benbalter/licensee`
2. `script/bootstrap`
3. `script/git-repo [URL to your repository]`

If Licensee cannot detect the license locally, [open an issue](https://github.com/benbalter/licensee/issues/new) and include the output of `script/git-repo`.

## Adding a license

Licensee doesn't curate any license information directly. Instead, we rely on the licenses and metadata provided by choosealicense.com and its much larger community (which can properly vet licenses and make determinations as to their properties).

Interested in adding support for Licensee to detect an additional license? Please [follow these instructions](https://github.com/github/choosealicense.com/blob/gh-pages/CONTRIBUTING.md#adding-a-license) to submit a pull request to get the license added upstream, and it will be automatically vendored (and detected) here.

## Updating the licenses

License data is pulled from `choosealicense.com`. To update the license data, simple run `script/vendor-licenses`.

## Bootstrapping a local development environment

`script/bootstrap`

## Running tests

`script/cibuild`

## Roadmap

See [proposed enhancements](https://github.com/benbalter/licensee/labels/enhancement).
