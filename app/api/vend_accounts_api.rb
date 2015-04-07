require 'grape'

require_relative '../models/vend_account'

module POSConnector
  module API
    class VendAccountsAPI < Grape::API
      resource 'vend-accounts' do
        desc 'Returns vend account.'
        get ':id' do
          vend_account = VendAccount.find(params[:id])
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
          vend_account = VendAccount.find(params[:id])

          vend_account.site_id = params[:site_id]
          vend_account.username = params[:username]
          if params[:last_poll_orders_datetime].to_s == ''
            vend_account.last_poll_orders_datetime = nil
          else
            begin
              vend_account.last_poll_orders_datetime = DateTime.parse(params[:last_poll_orders_datetime])
            rescue ArgumentError => exception
              puts exception.class.name, exception.message
              raise POSConnector::Exceptions::ValidationError, "Invalid Date Format - #{params[:last_poll_orders_datetime]}"
            end
          end
          if params[:password].to_s != ''
            vend_account.password = params[:password]
          end
          vend_account.save!

          vend_account
        end
      end
    end
  end
end
