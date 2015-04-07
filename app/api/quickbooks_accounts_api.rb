require 'grape'

require_relative '../models/quickbooks_account'
require_relative '../exceptions/validation_error'

module POSConnector
  module API
    class QuickbooksAccountsAPI < Grape::API
      resource 'quickbooks-accounts' do
        desc 'Returns Quickbooks account.'
        get ':id' do
          QuickbooksAccount.find params[:id]
        end

        desc 'Updates Quickbooks account.'
        params do
          requires :id, type: Integer
          requires :token, type: String
          requires :secret, type: String
          requires :realm_id, type: String
          requires :deposit_to_account_name, type: String
          requires :account_name, type: String
          requires :use_web_orders_user, type: Boolean
          requires :payment_method_map, type: String
        end
        put ':id' do
          quickbooks_account = QuickbooksAccount.find(params[:id])

          quickbooks_account.update_attributes!(
            :token => params[:token],
            :secret => params[:secret],
            :realm_id => params[:realm_id],
            :deposit_to_account_name => params[:deposit_to_account_name],
            :account_name => params[:account_name],
            :use_web_orders_user => params[:use_web_orders_user],
            :payment_method_map => params[:payment_method_map])

          quickbooks_account
        end
      end
    end
  end
end
