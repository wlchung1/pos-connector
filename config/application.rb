# Used bundler to require libraries originally
#require File.expand_path('../boot', __FILE__)

require 'yaml'
require 'active_record'
require 'logger'

# Establish database connection
db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))[ENV['APP_ENV']]
ActiveRecord::Base.logger = Logger.new STDOUT
ActiveRecord::Base.establish_connection(db_config)

require_relative '../app/main'
