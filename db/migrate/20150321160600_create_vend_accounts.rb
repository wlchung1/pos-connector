require 'active_record'

class CreateVendAccounts < ActiveRecord::Migration
  def self.up
    create_table(:vend_accounts) do |table|
      table.column :site_id, :string
      table.column :username, :string
      table.column :password, :string
      table.column :last_poll_orders_datetime, :datetime
    end
  end
 
  def self.down
    drop_table :vend_accounts
  end
end
