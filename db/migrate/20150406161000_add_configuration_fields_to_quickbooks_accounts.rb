require 'active_record'

class AddConfigurationFieldsToQuickbooksAccounts < ActiveRecord::Migration
  def change
    add_column :quickbooks_accounts, :deposit_to_account_name, :string
    add_column :quickbooks_accounts, :account_name, :string
    add_column :quickbooks_accounts, :use_web_orders_user, :boolean, :null => false, :default => true
    add_column :quickbooks_accounts, :payment_method_map, :text
  end
end
