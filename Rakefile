require 'yaml'
require 'active_record'
require 'logger'

namespace :db do
  task :set_environment do
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATION_DIR = ENV['MIGRATION_DIR'] || 'db/migrate'
  end

  task :load_config => :set_environment do
    @config = YAML.load_file('config/database.yml')[DATABASE_ENV]
  end

  task :establish_connection => :load_config do
    ActiveRecord::Base.logger = Logger.new STDOUT
    ActiveRecord::Base.establish_connection @config
  end

  desc 'Migrates the database (options: VERSION=x).'
  task :migrate => :establish_connection do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate MIGRATION_DIR, ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end
 
  desc 'Seeds the database with its default values.'
  task :seed => :establish_connection do
    require File.expand_path('../db/seeds', __FILE__)
  end

  desc 'Setups the database from scratch.'
  task :setup => [:drop, :migrate, :seed] do
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :establish_connection do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATION_DIR, step
  end

  desc 'Drops the database for the current DATABASE_ENV.'
  task :drop => :load_config do
    File.delete(@config['database']) if File.exist?(@config['database'])
  end
 
  desc 'Retrieves the current schema version number.'
  task :version => :establish_connection do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end
end
