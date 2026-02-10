# Development and Release

## Local Development

```sh
bin/setup
rake spec
bin/console
```

## Install Gem Locally

```sh
bundle exec rake install
```

## Release

```sh
bundle exec rake release
```

This creates a tag, pushes commits/tags, and publishes to RubyGems.
