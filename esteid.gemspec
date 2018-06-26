# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "esteid/version"

Gem::Specification.new do |spec|
  spec.name          = "esteid"
  spec.version       = EstEID::VERSION
  spec.authors       = ["Artem Pakk"]
  spec.email         = ["apakk@me.com"]

  spec.summary       = %q{A Ruby gem that assists in building authentication using Estonian ID card}
  spec.homepage      = "https://github.com/deskrock/esteid"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", ">= 2.4.0"
  spec.add_dependency "iconv"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
end
