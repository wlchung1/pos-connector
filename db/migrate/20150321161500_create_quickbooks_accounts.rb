require 'active_record'

class CreateQuickbooksAccounts < ActiveRecord::Migration
  def self.up
    create_table(:quickbooks_accounts) do |table|
      table.column :token, :string
      table.column :secret, :string
      table.column :realm_id, :string
    end
  end
 
  def self.down
    drop_table :quickbooks_accounts
  end
end
