require 'active_record'

class AddParametersContextToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :parameters, :text
    add_column :jobs, :context, :text
  end
end
