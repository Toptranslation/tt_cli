# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require 'toptranslation_cli/version'

Gem::Specification.new do |s|
  s.name          = 'toptranslation_cli'
  s.version       = ToptranslationCli::VERSION
  s.date          = '2016-06-23'
  s.summary       = 'Toptranslation command line client'
  s.description   = 'A gem for synching local files with Toptranslation translation service.'
  s.authors       = ['Stefan Rohde']
  s.email         = 'stefan.rohde@toptranslation.com'
  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.homepage      = 'https://developer.toptranslation.com'
  s.license       = 'MIT'

  s.add_runtime_dependency 'paint', '~> 1.0'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
end
