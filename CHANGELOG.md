<a name="1.0.2"></a>
### 1.0.2 (2020-02-18)

#### Bug Fixes

* use monkeypatch instead of a refinement to define Enumerable#each_in_threads	 ([5a2a7d6](/../commit/5a2a7d6))

<a name="1.0.1"></a>
### 1.0.1 (2019-10-08)

#### Bug Fixes

* rename a private method which was called by a a different name	 ([dc1e265](/../commit/dc1e265))
* make regex for placeholder paths case insensitive	 ([fe1d0dd](/../commit/fe1d0dd))

#### maintain

* make tt init use the same configuration as the other commands	 ([6b7370c](/../commit/6b7370c))

<a name="1.0.0"></a>
### 1.0.0 (2019-10-08)

#### Features

* show spinners for tt pull	 ([f798e74](/../commit/f798e74))
* show spinners for tt push	 ([65b4386](/../commit/65b4386))
* show spinner while fetching projects	 ([a30b512](/../commit/a30b512))
* preselect project guessed from pwd in tt init	 ([ecefdd6](/../commit/ecefdd6))
* show spinner while signing in from tt init	 ([1ed6da3](/../commit/1ed6da3))
* make tt init interactive	 ([01ce165](/../commit/01ce165))
* show progress bar for tt push	 ([9bb8369](/../commit/9bb8369))
* show progressbar for tt pull	 ([05bba1c](/../commit/05bba1c))
* add tt status command	 ([f265e64](/../commit/f265e64))
* use .toptranslation.yml as config file	 ([7a2ea17](/../commit/7a2ea17))
* don't swallow errors silently	 ([a31ed4a](/../commit/a31ed4a))
* show help message when no command is given	 ([0363b3e](/../commit/0363b3e))

#### Bug Fixes

* upload translations for the same document sequentially	 ([3183693](/../commit/3183693))
* fix deadlock issue by fetching all documents beforehand	 ([f713136](/../commit/f713136))
* correctly specify file format when downloading document	 ([c58fbba](/../commit/c58fbba))
* get identifier from created document	 ([15f0e45](/../commit/15f0e45))
* make sure help works with a subcommand	 ([af75810](/../commit/af75810))
* fix configuration spec	 ([e3d9c8d](/../commit/e3d9c8d))
* load gemspec from Gemfile	 ([7ff98a4](/../commit/7ff98a4))

#### maintain

* use github actions instead of travis-ci	 ([fb0763f](/../commit/fb0763f))
* list projects in tt init in alphabetical order	 ([bfd7a63](/../commit/bfd7a63))
* update .rubocop-todo.yml	 ([feab797](/../commit/feab797))
* remove paint and use pastel everywhere	 ([60e364c](/../commit/60e364c))
* calculate sha1 sums of local files before uploading	 ([5c70218](/../commit/5c70218))
* update toptranslation_api to 2.3	 ([1de342c](/../commit/1de342c))
* don't set file_type when pulling	 ([918cb9d](/../commit/918cb9d))
* use toptranslation_api ~> 2.2	 ([ffe9159](/../commit/ffe9159))
* use Thor to handle command line options	 ([b29c729](/../commit/b29c729))
* set required ruby version to >= 2.3	 ([e980f2e](/../commit/e980f2e))
* run non-verbose by default to avoid leaking access tokens	 ([f1a1348](/../commit/f1a1348))
* use some sensible rspec settings from bundlers default config	 ([92ed15c](/../commit/92ed15c))
* use pry	 ([e0b200c](/../commit/e0b200c))
* update to toptranslation_api ~> 2.0	 ([e3960c3](/../commit/e3960c3))
* add rubocop to default rake task	 ([11de902](/../commit/11de902))
* specify rubocop and rubocop-rspec version	 ([c513de0](/../commit/c513de0))
* update MIT license Copyright	 ([e6f03cc](/../commit/e6f03cc))
* remote Gemfile.lock	 ([17cfaa5](/../commit/17cfaa5))
* use travis-ci	 ([90c4ffd](/../commit/90c4ffd))
* add .ruby-version file	 ([0bbf497](/../commit/0bbf497))
* change toptranslation_api git url to github	 ([b2fa1d5](/../commit/b2fa1d5))

#### formatting, missing semi colons, …

* fix rubocop offenses from .rubocop_todoy.yml	 ([f1fb401](/../commit/f1fb401))
* satisfy rubocop	 ([608186c](/../commit/608186c))
* change rubocop target ruby version to 2.3	 ([1826381](/../commit/1826381))
* use rubocop	 ([68af8ce](/../commit/68af8ce))
* some refactoring based on the output of `bundle gem`	 ([1177161](/../commit/1177161))

