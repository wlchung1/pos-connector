require 'grape'

require_relative '../models/vend_account'

module POSConnector
  module API
    class VendAccountsAPI < Grape::API
      resource 'vend-accounts' do
        desc 'Returns vend account.'
        get ':id' do
          vend_account = POSConnector::Models::VendAccount.find(params[:id])
          vend_account.password = ''
          vend_account
        end

        desc 'Updates vend account.'
        params do
          requires :id, type: Integer
          requires :site_id, type: String
          requires :username, type: String
          requires :last_poll_orders_datetime, type: String
          optional :password, type: String
        end
        put ':id' do
          vendAccount = POSConnector::Models::VendAccount.find(params[:id])

          vendAccount.site_id = params[:site_id]
          vendAccount.username = params[:username]
          if params[:last_poll_orders_datetime].to_s == ''
            vendAccount.last_poll_orders_datetime = nil
          else
            begin
              vendAccount.last_poll_orders_datetime = DateTime.parse(params[:last_poll_orders_datetime])
            rescue ArgumentError => exception
              puts exception.class.name, exception.message
              raise POSConnector::Exceptions::ValidationError, "Invalid Date Format - #{params[:last_poll_orders_datetime]}"
            end
          end
          if params[:password].to_s != ''
            vendAccount.password = params[:password]
          end
          vendAccount.save!()

          vendAccount
        end
      end
    end
  end
end
