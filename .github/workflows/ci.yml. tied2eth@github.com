name: CI

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        ruby: [2.5, 2.6, 2.7, 3.0]

    steps:
      - uses: actions/checkout@v2
      - name: Set up Ruby

        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true # runs 'bundle install' and caches installed gems automatically

      - name: Setup Git
        run: |
          git config --global user.email "you@example.com"
          git config --global user.name "Your Name"

      - name: Run tests
        run: script/cibuild
