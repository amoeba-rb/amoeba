# frozen_string_literal: true

require 'rails'
require 'active_storage/engine'
require 'action_text/engine'

# Load Action Text through its engine, as a Rails application would.
class ActionTextTestApplication < Rails::Application
  config.eager_load = false
  config.paths['config/database'] = [File.expand_path('database.yml', __dir__)]
  config.secret_key_base = 'amoeba-action-text-tests'
  config.active_storage.service = :test
  config.active_storage.service_configurations = {
    test: { service: 'Disk', root: File.join(Dir.tmpdir, 'amoeba-action-text') }
  }
end

ActionTextTestApplication.initialize!
