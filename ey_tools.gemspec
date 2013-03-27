# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ey_tools/version'

Gem::Specification.new do |spec|
  spec.name          = "ey_tools"
  spec.version       = EY::Tools::VERSION
  spec.authors       = ["Andrey Deryabin"]
  spec.email         = ["deriabin@gmail.com"]
  spec.description   = %q{Extension for EY for rails developers}
  spec.summary       = %q{Extension for EY for rails developers}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md)
  spec.executables = ["ey-console"]
  spec.test_files = Dir.glob("spec/**/*")
  spec.require_paths = ["lib"]

  spec.add_dependency "engineyard"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
