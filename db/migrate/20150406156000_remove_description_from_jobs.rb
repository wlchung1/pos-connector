require 'active_record'

class RemoveDescriptionFromJobs < ActiveRecord::Migration
  def up
    remove_column :jobs, :description
  end
  
  def down
    add_column :jobs, :description, :text
  end
end
