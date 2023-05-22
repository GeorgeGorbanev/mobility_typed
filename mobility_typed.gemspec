# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mobility_typed/version'

Gem::Specification.new do |spec|
  spec.name          = 'mobility_typed'
  spec.version       = MobilityTyped.gem_version
  spec.authors       = ['George Gorbanev']
  spec.email         = ['georgegorbanev@gmail.com']

  spec.required_ruby_version = '>= 2.5'

  spec.summary       = 'Ruby Mobility gem plugin designed to add type checking for translated attributes'
  spec.description   = <<~DESCRIPTION
    This gem adds Mobility plugin, which can be turned on for Rails model,
    and will check types of values passed to setters.
  DESCRIPTION

  spec.homepage = 'https://github.com/georgegorbanev/mobility_typed'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/georgegorbanev/mobility_typed'

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.files = Dir['{lib/**/*,[A-Z]*}']
  spec.require_paths = ['lib']

  spec.add_dependency 'mobility', '~> 1.1.3'
  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.86.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.40.0'
end
