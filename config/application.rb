require_relative 'boot'

require 'yaml'
require 'active_record'
require 'logger'
require 'quickbooks-ruby'

# Establish database connection
db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))[ENV['APP_ENV']]
ActiveRecord::Base.logger = Logger.new STDOUT
ActiveRecord::Base.establish_connection(db_config)

# Configure Quickbooks' Oauth settings
require_relative 'quickbooks'
