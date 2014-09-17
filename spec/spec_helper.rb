require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'spec'
  minimum_coverage(76)
end
require 'active_record'
require 'amoeba'

adapter = if defined?(JRuby)
            require 'activerecord-jdbcsqlite3-adapter'
            'jdbcsqlite3'
          else
            require 'sqlite3'
            'sqlite3'
          end

ActiveRecord::Base.establish_connection(adapter: adapter, database: ':memory:')

::RSpec.configure do |config|
  config.order = :default
end

load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/models.rb'
