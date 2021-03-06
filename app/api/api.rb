require 'grape'

# Load all the other API files
Dir[File.expand_path('../*.rb', __FILE__)].each do |file|
  if file != __FILE__
    require file
  end
end

module POSConnector
  module API
    class API < Grape::API
      include POSConnector::API::APIExceptionHandler

      #version 'v1', using: :path
      format :json
      prefix :api

      mount JobsAPI
      mount OrdersAPI
      mount QuickbooksAccountsAPI
      mount QuickbooksAuthorizationAPI
      mount VendAccountsAPI
    end
  end
end
