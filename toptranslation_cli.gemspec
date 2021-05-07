# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require 'toptranslation_cli/version'

Gem::Specification.new do |s| # rubocop:disable Metrics/BlockLength
  s.name                  = 'toptranslation_cli'
  s.version               = ToptranslationCli::VERSION
  s.summary               = 'Toptranslation command line client'
  s.description           = 'A gem for synching local files with Toptranslation translation service.'
  s.authors               = ['Toptranslation GmbH']
  s.email                 = 'tech@toptranslation.com'
  s.files                 = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir                = 'exe'
  s.executables           = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.homepage              = 'https://developer.toptranslation.com'
  s.license               = 'MIT'
  s.metadata              = { 'source_code_uri' => 'https://github.com/Toptranslation/tt_cli' }
  s.required_ruby_version = '>= 2.7'

  s.add_runtime_dependency 'pastel', '~> 0.7'
  s.add_runtime_dependency 'thor', '~> 0.20'
  s.add_runtime_dependency 'toptranslation_api', '~> 2.5'
  s.add_runtime_dependency 'tty-progressbar', '~> 0.17'
  s.add_runtime_dependency 'tty-prompt', '~> 0.16'
  s.add_runtime_dependency 'tty-spinner', '~> 0.8'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rubocop', '~> 1.14.0'
  s.add_development_dependency 'rubocop-rspec', '~> 2.3.0'
end
