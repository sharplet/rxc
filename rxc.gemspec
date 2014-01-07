# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rxc/version'

Gem::Specification.new do |spec|
  spec.name          = "rxc"
  spec.version       = RXC::VERSION
  spec.authors       = ["Adam Sharp"]
  spec.email         = ["adam.sharp@outware.com.au"]
  spec.summary       = %q{A collection of utilities for working with Xcode projects.}
  spec.homepage      = ""
  spec.license       = "No License"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'xcpretty'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
