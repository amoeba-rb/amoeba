# frozen_string_literal: true

require 'bundler/setup'
require 'active_record'
require 'amoeba'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.expand_path('../db/example.sqlite3', __dir__)
)

Dir[File.expand_path('../app/models/*.rb', __dir__)].sort.each { |file| require file }
