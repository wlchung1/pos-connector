require 'active_record'

require_relative 'job'
require_relative 'order'
require_relative 'vend_account'
require_relative '../exceptions/job_error'
require_relative '../exceptions/validation_error'
require_relative '../vend/client'
require_relative '../vend/vend_endpoint_error'

class ReceiveOrdersFromVendJob < Job
  attr_accessor :vend_client_class
  after_initialize :after_initialize

  def after_initialize
    @vend_client_class = POSConnector::Vend::Client
  end

  def run
    begin
      puts 'Getting Vend account...'
      vend_account = VendAccount.find(1)

      # Basic validations
      if vend_account.site_id.to_s == ''
        raise POSConnector::Exceptions::ValidationError, 'Site ID Not Configured'
      end
      if vend_account.username.to_s == ''
        raise POSConnector::Exceptions::ValidationError, 'Username Not Configured'
      end
      if vend_account.password.to_s == ''
        raise POSConnector::Exceptions::ValidationError, 'Password Not Configured'
      end

      puts 'Retrieving orders from Vend...'
      vend_client = @vend_client_class.new(vend_account.site_id, vend_account.username, vend_account.password)
      vend_orders = vend_client.get_orders(vend_account.last_poll_orders_datetime)

      puts "Processing #{vend_orders.size} Vend orders..."
      vend_orders.each do |vend_order|
        vend_order_updated_at = DateTime.strptime(vend_order['updated_at'], '%Y-%m-%d %H:%M:%S')
        order = Order.find_by source: Order::SOURCE_VEND, order_number: vend_order[:id]

        if order.nil?
          puts "Creating order #{vend_order[:id]}"
          Order.create!(
            :message => vend_order.to_json,
            :source => Order::SOURCE_VEND,
            :order_number => vend_order[:id],
            :last_updated_datetime => vend_order_updated_at,
            :quickbooks_sync_status => Order::QUICKBOOKS_SYNC_STATUS_NOT_STARTED
          )
        else
          if vend_order_updated_at > order.last_updated_datetime
            puts "Updating order #{vend_order[:id]}"

            order.message = vend_order.to_json
            order.last_updated_datetime = vend_order_updated_at
            if order.quickbooks_sync_status == Order::QUICKBOOKS_SYNC_STATUS_SUCCEEDED
              order.quickbooks_sync_status = Order::QUICKBOOKS_SYNC_STATUS_STALE
            end
            order.save!
          else
            puts "Skipping order #{vend_order[:id]}"
          end
        end
      end

      # Update the last poll orders datetime
      # so that the same set of orders will not be polled again.
      vend_account.last_poll_orders_datetime = start_datetime
      vend_account.save!
    rescue POSConnector::Vend::VendEndpointError => exception
      raise POSConnector::Exceptions::JobError, exception.message
    end
  end
end
