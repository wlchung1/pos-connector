require 'active_record'

class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table(:orders) do |table|
      table.column :message, :text, :null => false
      table.column :source, :string, :null => false
      table.column :order_number, :string, :null => false
      table.column :last_updated_datetime, :datetime
      table.column :quickbooks_sync_message, :text
      table.column :quickbooks_sync_status, :string, :null => false

      table.index [:source, :order_number], unique: true
    end
  end

  def self.down
    drop_table :orders
  end
end
