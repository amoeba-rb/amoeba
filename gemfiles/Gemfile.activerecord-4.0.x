source "https://rubygems.org"

gemspec :path => '..'

gem 'activerecord', '~> 4.0.0'
gem 'sqlite3'

group :development do
  gem 'rake'
  gem 'coveralls', require: false
end
