source "https://rubygems.org"

gemspec :path => '..'

gem 'activerecord', '~> 3.2.6'
gem 'sqlite3'

group :development do
  gem 'rake'
  gem 'coveralls', require: false
end
