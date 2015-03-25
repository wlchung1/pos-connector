require 'active_record'

class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table(:jobs) do |table|
      table.column :flow_type, :string, :null => false
      table.column :status, :string, :null => false
      table.column :start_datetime, :datetime
      table.column :end_datetime, :datetime
      table.column :description, :text
      table.column :error_message, :text
    end
  end

  def self.down
    drop_table :jobs
  end
end
