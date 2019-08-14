# toptranslation_cli
Gem to provide a command line tool for synching documents with the Toptranslation translations service.

## Installation

Install `toptranslation_cli` via `gem install`

```
$ gem install toptranslation_cli
```

or add it as a dependency to your project's Gemfile

```ruby
gem 'toptranslation_cli', group: :development
```

## Configuration

Configuration is stored in `.toptranslation.yml`. A configuration can be created with [`$ tt init`](#initialization). The configuration can be checked with [`$ tt check`](#check-configuration).

### Example configuration

An example configuration file `.toptranslation.yml:

```yaml
project_identifier: "<PROJECT_IDENTIFIER>"
access_token: "<YOUR_ACCESS_TOKEN>"
files:
  - config/locales/{locale_code}/**/*.yml # matches config/locales/en/foo.yml
  - config/locales/**/*.{locale_code}.yml # matches config/locales/foo.en.yml
```

#### Used attributes:
+ **project_identifier** - Identifier of the synched project (see project settings in Toptranslation dashboard)
+ **access_token** - An access token used for authentication (see project settings in Toptranslation dashboard)
+ **files** - An array of paths that will be used to find documents to be synched. The path attribute may use wildcards like `/**/` or `*.yml` and placeholders (see below).

#### Placeholders in paths

+ **{locale_code}** - Will be replaced with the locale code of project locales

## Usage

### Initialization

Starts an interactive configuration dialog that will generate a `.toptranslation.yml` configuration.

```
tt init
```

[![asciicast](https://asciinema.org/a/3wFSWXz5Z7YCDQB1necBXsSoc.png)](https://asciinema.org/a/3wFSWXz5Z7YCDQB1necBXsSoc)

### Check configuration

Checks configuration settings in `.toptranslation.yml` and counts files matching the file path definitions (see configuration).

```bash
$ tt check
Toptranslation command line client, version 1.0.0 - Configuration check

Configuration file present:     ok
 * includes access_token:       ok
 * includes project_identifier: ok
 * includes files:              ok

Matching files:
 * config/locales/{locale_code}/**/*.yml: 3 matching files
```

### Status

Shows which files differ or exist only locally/remotely.

```bash
$ tt status
Local: These documents exist only locally

	config/locales/de/new.yml

Changed: These documents exist both locally and remotely but differ

	config/locales/en/changed.yml

Remote: These documents exist only remotely

	config/locales/fr/foo.yml
```

### Push local documents

Pushes locals translations to Toptranslation.

```bash
$ tt push
```

[![asciicast](https://asciinema.org/a/3HT7WtvkQG3Zs3XO3orBeOdb3.svg)](https://asciinema.org/a/3HT7WtvkQG3Zs3XO3orBeOdb3)

### Pull remote translations

Pulls translations from Toptranslation and overwrites local translations.

```bash
$ tt pull
```

[![asciicast](https://asciinema.org/a/MrW1FGaAgljvWO3r9V6mCa3Pi.svg)](https://asciinema.org/a/MrW1FGaAgljvWO3r9V6mCa3Pi)

### Help

Display help page with usage instructions, examples and contact options.

```
$ tt help
Toptranslation command line client, version 0.2.0

tt commands:
  tt check    # Check current configuration
  tt help     # Print usage information
  tt init     # Create a .toptranslation.yml configuration
  tt pull     # Download remote translations, overwriting local documents
  tt push     # Upload local documents
  tt status   # Show local documents that differ from remote documents
  tt version  # Print version

twitter:
  @tt_developers (https://twitter.com/tt_developers)

websites:
  https://www.toptranslation.com
  https://developer.toptranslation.com
  https://github.com/Toptranslation/tt_cli
```

### Version

Displays the current version of this software.

```
$ tt version
Toptranslation command line client, version 0.2.0
```

## Contact
Web: [https://developer.toptranslation.com](https://developer.toptranslation.com) or
[https://www.toptranslation.com](https://www.toptranslation.com)

Github: [https://www.github.com/toptranslation](https://www.github.com/toptranslation)

Twitter: [@tt_developers](http://www.twitter.com/tt_developers) or [@toptranslation](http://www.twitter.com/toptranslation)

Mail: tech@toptranslation.com
