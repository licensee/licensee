# Contributing to Licensee

Interested in contributing to Licensee? We’d love your help. Licensee is an open source project, built one contribution at a time by users like you.

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
