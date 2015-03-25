require_relative '../models/job'
require_relative '../models/order'
require_relative '../vend/client'
require_relative '../vend/vend_endpoint_error'
require_relative '../exceptions/validation_error'

module POSConnector
  module Services
    class JobService
      # Aliases for accessing classes
      Job = POSConnector::Models::Job
      private_constant :Job
      Order = POSConnector::Models::Order
      private_constant :Order

      def initialize(vend_client_class = POSConnector::Vend::Client)
        @vend_client_class = vend_client_class
      end

      def create_receive_orders_from_vend_job(params)
        puts 'Getting Vend account...'
        vend_account = POSConnector::Models::VendAccount.find(1)

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

        puts 'Creating job...'
        job = Job.create(
          :flow_type => params[:flow_type],
          :status => Job::STATUS_RUNNING,
          :start_datetime => Time.now,
          :description => "Receive Orders from Vend {Polled From: #{vend_account.last_poll_orders_datetime}}")

        begin
          puts 'Retrieving orders from Vend...'
          vend_client = @vend_client_class.new(vend_account.site_id, vend_account.username, vend_account.password)
          vend_orders = vend_client.get_orders(vend_account.last_poll_orders_datetime)

          puts "Processing #{vend_orders.size} Vend orders..."
          ActiveRecord::Base.transaction do
            vend_orders.each do |vend_order|
              vend_order_updated_at = DateTime.strptime(vend_order['updated_at'], '%Y-%m-%d %H:%M:%S')
              order = Order.find_by source: Order::SOURCE_VEND, order_number: vend_order[:id]

              if order == nil
                puts "Creating order #{vend_order[:id]}"
                Order.create(
                  :message => vend_order.to_s,
                  :source => Order::SOURCE_VEND,
                  :order_number => vend_order[:id],
                  :last_updated_datetime => vend_order_updated_at,
                  :quickbooks_sync_status => Order::QUICKBOOKS_SYNC_STATUS_NOT_STARTED
                )
              else
                if vend_order_updated_at > order.last_updated_datetime
                  puts "Updating order #{vend_order[:id]}"

                  order.message = vend_order.to_s
                  order.last_updated_datetime = vend_order_updated_at
                  if order.quickbooks_sync_status == Order::QUICKBOOKS_SYNC_STATUS_SUCCEEDED
                    order.quickbooks_sync_status == Order::QUICKBOOKS_SYNC_STATUS_STALE
                  end
                  order.save!
                else
                  puts "Skipping order #{vend_order[:id]}"
                end
              end
            end

            # Update the last poll orders datetime
            # so that the same set of orders will not be polled again.
            vend_account.last_poll_orders_datetime = job.start_datetime
            vend_account.save!
          end

          # Job succeeded if it arrives here
          job.status = Job::STATUS_SUCCEEDED
        rescue POSConnector::Exceptions::ValidationError, POSConnector::Vend::VendEndpointError => exception
          puts "Job #{job.id} failed: #{exception.class.name} - #{exception.message} "

          job.status = Job::STATUS_FAILED
          job.error_message = exception.message
          raise exception
        rescue Exception => exception
          puts "Job #{job.id} failed: #{exception.class.name} - #{exception.message} "

          job.status = Job::STATUS_FAILED
          job.error_message = 'Internal Server Error'
          raise exception
        ensure
          job.end_datetime = Time.now
          job.save!
        end
      end
    end
  end
end
