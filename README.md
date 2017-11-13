# toptranslation_cli
Gem to provide a command line tool for synching documents with the Toptranslation translations service.

## Configuration

Configuration is stored in `toptranslation.json`. An example configuration can be created with `$ tt init`. The configuration can be checked with `$ tt check` (see Usage: Check configuration).

### Example configuration

An example configuration file `toptranslation.json:

```json
{
  "project_identifier": "<PROJECT_IDENTIFIER>",
  "access_token": "<YOUR_ACCESS_TOKEN>",
  "files": [
    {
      "path": "config/locales/{locale_code}/**/*.yml"
    }
  ]
}
```

#### Used attributes:
+ **project_identifier** - Identifier of the synched project (see project settings in Toptranslation dashboard)
+ **access_token** - An access token used for authentication (see project settings in Toptranslation dashboard)
+ **files** - An array of paths that will be used to find documents to be synched. The path attribute may use wildcards like `/**/` or `*.yml` and placeholders (see below).

#### Placeholders in paths

+ **{locale_code}** - Will be replaced with the locale code of project locales

## Usage

### Initialisation

Creates an `toptranslation.json configuration in the current directory with example values.

```bash
$ tt init
=> Creating example configuration in 'toptranslation.json'.
=> See https://developer.toptranslation.com for configuration instructions.
```

### Check configuration

Checks configuration settings in `toptranslation.json` and counts files matching the file path definitions (see configuration).

```bash
$ tt check
=> Toptranslation command line client, version 1.0.0 - Configuration check

   Configuration file present: ok
    * includes access_token:   ok
    * includes project_identifier: ok
    * includes files:      ok

   Matching files:
    * config/locales/{locale_code}/**/*.yml: 3 matching files
```

### Push local documents

Pushes locals documents to Toptranslation.

```bash
$ tt push
```

### Pull remote translations

Pulls translations from Toptranslation and overwrites local translations.

```bash
$ tt pull
```

### Help

Displays help page with usage instructions, examples and contact options.

```
$ tt --help
=> Toptranslation command line client, version 1.0.0
   Usage: tt [command]
   Commands: ...
```

### Version

Displays the current version of this software.

```
$ tt --version
=> Toptranslation command line client, version 1.0.0
```

## Contact
Web: [https://developer.toptranslation.com](https://developer.toptranslation.com) or
[https://www.toptranslation.com](https://www.toptranslation.com)

Github: [https://www.github.com/toptranslation](https://www.github.com/toptranslation)

Twitter: [@tt_developers](http://www.twitter.com/tt_developers) or [@toptranslation](http://www.twitter.com/toptranslation) 

Mail: tech@toptranslation.com
