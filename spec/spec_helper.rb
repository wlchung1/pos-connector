ENV['APP_ENV'] ||= 'test'

require_relative '../config/environment'

require 'active_record'
require 'rspec'

# Setup the database
ActiveRecord::Migrator.migrate 'db/migrate'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
  config.raise_errors_for_deprecations!

  config.around do |example|
    # Rollback transaction after each test so that tests will not influence each others
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
