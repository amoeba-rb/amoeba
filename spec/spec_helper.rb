require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
  minimum_coverage(76)

  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end
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
