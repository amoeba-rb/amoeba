# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amoeba/version"

Gem::Specification.new do |s|
  s.name        = "amoeba"
  s.version     = Amoeba::VERSION
  s.authors     = ["Vaughn Draughon"]
  s.homepage    = "http://github.com/rocksolidwebdesign/amoeba"
  s.license     = "BSD"
  s.summary     = %q{Easy copying of rails models and their child associations.}
  s.description = %q{An extension to ActiveRecord to allow the duplication method to also copy associated children, with recursive support for nested of grandchildren. The behavior is controllable with a simple DSL both on your rails models and on the fly, i.e. per instance. Numerous configuration options and styles and preprocessing directives are included for power and flexibility.}

  s.rubyforge_project = "amoeba"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.3"

  s.add_development_dependency "sqlite3-ruby"

  s.add_dependency "activerecord", ">= 3.0"
end
