$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "toptranslation_cli/version"

Gem::Specification.new do |s|
  s.name          = 'toptranslation_cli'
  s.version       = ToptranslationCli::VERSION
  s.date          = '2016-06-23'
  s.summary       = "Toptranslation command line client"
  s.description   = "A gem for synching local files with Toptranslation translation service."
  s.authors       = ["Stefan Rohde"]
  s.email         = 'stefan.rohde@toptranslation.com'
  s.files         = Dir["{lib}/**/*"]
  s.executables   = ["tt"]
  s.homepage      = 'https://developer.toptranslation.com'
  s.license       = 'MIT'

  s.add_runtime_dependency 'paint', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 3.4'
end
