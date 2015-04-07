require 'active_record'

class RemoveQuickbooksSyncMessageFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :quickbooks_sync_message
  end

  def down
    add_column :orders, :quickbooks_sync_message, :text
  end
end
