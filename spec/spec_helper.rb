# frozen_string_literal: true

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

begin
  ActiveRecord::Base.establish_connection(adapter: adapter, database: ':memory:')
rescue ActiveRecord::AdapterNotFound
  # activerecord-jdbc-adapter >= 80.0 registers itself under the standard 'sqlite3' name
  raise unless adapter == 'jdbcsqlite3'

  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
end

::RSpec.configure do |config|
  config.order = :defined
end

load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/models.rb'
