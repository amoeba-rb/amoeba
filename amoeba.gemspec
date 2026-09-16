# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'amoeba/version'

Gem::Specification.new do |s|
  s.name                  = 'amoeba'
  s.version               = Amoeba::VERSION
  s.authors               = ['Vaughn Draughon', 'Oleksandr Simonov', 'Joseph Haig']
  s.email                 = 'josephhaig@gmail.com'
  s.homepage              = 'https://github.com/amoeba-rb/amoeba'
  s.license               = 'BSD-2-Clause'
  s.summary               = 'Easy copying of ActiveRecord models and their child associations.'
  s.description           = <<~DESCRIPTION
    Duplicate ActiveRecord models and their nested child associations with configurable cloning behavior.
  DESCRIPTION
  s.required_ruby_version = '>= 3.2'

  s.metadata = {
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    'changelog_uri' => "#{s.homepage}/CHANGELOG.md",
    'bug_tracker_uri' => "#{s.homepage}/issues"
  }

  s.files = Dir['lib/**/*', 'README.md', 'docs/**/*', 'LICENSE.md', 'CHANGELOG.md']
  s.add_dependency 'activerecord', '>= 7.1.0'
end
