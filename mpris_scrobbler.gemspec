# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mpris_scrobbler'

Gem::Specification.new do |spec|
  spec.name          = "mpris_scrobbler"
  spec.version       = MprisScrobbler::VERSION
  spec.authors       = ["Bruno Antunes"]
  spec.email         = ["sardaukar.siet@gmail.com"]

  spec.summary       = %q{Last.fm scrobbler for Linux music players that follow the MPRIS 2 specification}
  spec.description   = ""
  spec.homepage      = "https://github.com/sardaukar/mpris_scrobbler"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rockstar"
  spec.add_dependency "ruby-dbus"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
