# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'amoeba/version'

Gem::Specification.new do |s|
  s.name        = 'amoeba'
  s.version     = Amoeba::VERSION
  s.authors     = ['Vaughn Draughon', 'Oleksandr Simonov']
  s.email       = 'alex@simonov.me'
  s.homepage    = 'http://github.com/amoeba-rb/amoeba'
  s.license     = 'BSD-2-Clause'
  s.summary     = 'Easy copying of rails models and their child associations.'
  s.required_ruby_version = '>= 2.5'

  s.description = <<~DESCRIPTION
    An extension to ActiveRecord to allow the duplication method to also copy associated children, with recursive support for nested of grandchildren. The behavior is controllable with a simple DSL both on your rails models and on the fly, i.e. per instance. Numerous configuration styles and preprocessing directives are included for power and flexibility. Supports preprocessing of field values to prepend strings such as "Copy of ", to nullify or process field values with regular expressions. Supports most association types including has_one :through and has_many :through.

    Tags: copy child associations, copy nested children, copy associated child records, nested copy, copy associations, copy relations, copy relationships, duplicate associations, duplicate associated records, duplicate child records, duplicate children, copy all, duplicate all, clone child associations, clone nested children, clone associated child records, nested clone, clone associations, clone relations, clone relationships, cloning child associations, cloning nested children, cloning associated child records, deep_cloning, nested cloning, cloning associations, cloning relations, cloning relationships, cloning child associations, cloning nested children, cloning associated child records, nested cloning, cloning associations, cloning relations, cloning relationships, cloning child associations, cloning nested children, cloning associated child records, deep_cloning, nested cloning, cloning associations, cloning relations, cloning relationships, duplicate child associations, duplicate nested children, duplicate associated child records, nested duplicate, duplicate associations, duplicate relations, duplicate relationships, duplicate child associations, duplicate nested children, duplicate associated child records, deep_duplicate, nested duplicate, duplicate associations, duplicate relations, duplicate relationships, deep_copy, deep_clone, deep_cloning, deep clone, deep cloning, has_one, has_many, has_and_belongs_to_many
  DESCRIPTION

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'rubocop', '~> 1.56'
  s.add_development_dependency 'rubocop-rake', '~> 0.6'
  s.add_development_dependency 'rubocop-rspec', '~> 2.24'

  if RUBY_PLATFORM == 'java'
    s.add_development_dependency 'activerecord-jdbc-adapter', '~> 70.0'
    s.add_development_dependency 'activerecord-jdbcsqlite3-adapter', '~> 70.0'
  else
    s.add_development_dependency 'sqlite3', '~> 1.6.0'
  end

  s.add_dependency 'activerecord', '>= 6.0.0'
end
