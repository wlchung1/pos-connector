require 'active_record'

class CreateIndexJobsOnStatus < ActiveRecord::Migration
  def up
    # No bitmap index available in SQLite3
    add_index :jobs, :status
  end

  def down
    remove_index :jobs, :status
  end
end
