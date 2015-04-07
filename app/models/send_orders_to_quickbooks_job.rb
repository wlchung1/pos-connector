require 'active_record'
require 'json'
require 'quickbooks-ruby'

require_relative 'job'
require_relative 'order'
require_relative 'quickbooks_account'
require_relative '../exceptions/job_error'
require_relative '../exceptions/validation_error'
require_relative '../qb_integration/qb_integration'

class SendOrdersToQuickbooksJob < Job

  def validate(quickbooks_account)
    # Basic validations
    if quickbooks_account.token.to_s == ''
      raise POSConnector::Exceptions::ValidationError, 'Token Not Configured'
    end
    if quickbooks_account.secret.to_s == ''
      raise POSConnector::Exceptions::ValidationError, 'Secret Not Configured'
    end
    if quickbooks_account.realm_id.to_s == ''
      raise POSConnector::Exceptions::ValidationError, 'Realm ID Not Configured'
    end

    if (parameters.to_s == '')
      raise POSConnector::Exceptions::ValidationError, 'Order IDs Not Specified in Parameters'
    end
  end

  def run
    begin
      puts 'Getting Quickbooks account...'
      quickbooks_account = QuickbooksAccount.find(1)

      validate quickbooks_account

      # Retrieving the list of orders to send
      parameters_hash = JSON.parse(parameters)
      orders = Order.where(:id => parameters_hash['ids'])

      puts "Going to send #{orders.size} orders to Quickbooks..."

      # Get the order messages from context if context exists
      if context.to_s == ''
        context_hash = {}
      else
        context_hash = JSON.parse(context)
      end

      orders.each do |order|
        begin
          puts "Sending order #{order.id} to Quickbooks..."

          order_message = context_hash[order.id.to_s]
          if order_message.to_s == ''
            # Render message if it does not exist in context
            order_message = JSON.parse(order.message)
            
            # Quickbooks basically does not support GUID as the order ID
            # since its maximum length allowed for order ID is 21 only.
            # Set the number attribute such that the internal generated integral order ID will be used instead. 
            order_message['number'] = order.id

            context_hash[order.id.to_s] = order_message

            # Update context such that message can be fixed manually if error occurs later
            puts "Inserting message into context"
            update_attributes! :context => context_hash.to_json
          end

          quickbooks_order = POSConnector::QBIntegration::Order.new({:order => order_message},
            {'quickbooks_realm' => quickbooks_account.realm_id,
             'quickbooks_access_token' => quickbooks_account.token,
             'quickbooks_access_secret' => quickbooks_account.secret,
             'quickbooks_deposit_to_account_name' => quickbooks_account.deposit_to_account_name,
             'quickbooks_account_name' => quickbooks_account.account_name,
             'quickbooks_web_orders_user' => quickbooks_account.use_web_orders_user,
             'quickbooks_payment_method_name' => quickbooks_account.payment_method_map})

          quickbooks_order.create_or_update

          order.quickbooks_sync_status = Order::QUICKBOOKS_SYNC_STATUS_SUCCEEDED
        rescue Exception => exception
          order.quickbooks_sync_status = Order::QUICKBOOKS_SYNC_STATUS_FAILED

          # Abort if exception occurs
          raise exception
        ensure
          order.save!
        end
      end
    rescue POSConnector::QBIntegration::QBIntegrationException,
           Quickbooks::IntuitRequestException,
           Quickbooks::InvalidModelException,
           Quickbooks::AuthorizationFailure,
           Quickbooks::Forbidden,
           Quickbooks::ServiceUnavailable,
           Quickbooks::MissingRealmError => exception
      puts exception.class.name, exception.message, exception.backtrace
      raise POSConnector::Exceptions::JobError, exception.message
    end
  end
end
