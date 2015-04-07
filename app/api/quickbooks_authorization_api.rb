require 'grape'
require 'quickbooks-ruby'

require_relative '../qb_integration/auth'

module POSConnector
  module API
    class QuickbooksAuthorizationAPI < Grape::API
      resource 'quickbooks-authorization/get-oauth-token' do
        desc 'Returns OAuth token.'
        get do
          auth = POSConnector::QBIntegration::Auth.new

          env['rack.session'][:quickbooks_oauth_request_token] = auth.consumer.get_request_token

          {:oauth_token => env['rack.session'][:quickbooks_oauth_request_token].token}
        end
      end

      resource 'quickbooks-authorization/oauth-callback' do
        desc 'Saves token and secret for OAuth callback.'
        params do
          requires :id, type: Integer
          requires :oauth_verifier, type: String
          requires :realm_id, type: String
        end
        put do
          quickbooks_oauth_request_token = env['rack.session'][:quickbooks_oauth_request_token]

          if quickbooks_oauth_request_token.nil?
            raise POSConnector::Exceptions::ValidationError, 'OAuth Request Token Not Initialized'
          end
          access_token = quickbooks_oauth_request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])

          quickbooks_account = QuickbooksAccount.find(params[:id])
          quickbooks_account.update_attributes!(
            :token => access_token.token,
            :secret => access_token.secret,
            :realm_id => params[:realm_id])

          # Clear session after OAuth information has been saved
          env['rack.session'][:quickbooks_oauth_request_token] = nil
        end
      end
    end
  end
end
