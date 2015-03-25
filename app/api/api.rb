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

      mount POSConnector::API::JobCreationAPI
      mount POSConnector::API::JobsAPI
      mount POSConnector::API::OrdersAPI
      mount POSConnector::API::VendAccountsAPI
    end
  end
end
