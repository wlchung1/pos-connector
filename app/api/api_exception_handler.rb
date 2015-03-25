require 'active_record'
require 'grape'

require_relative '../exceptions/validation_error'

module POSConnector
  module API
    module APIExceptionHandler
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordNotFound do |exception|
          puts exception.message
          # Better not to return sensitive error message
          error_response(message: 'Record Not Found', status: 404)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |exception|
          puts exception.message
          error_response(message: exception.message, status: 400)
        end

        rescue_from POSConnector::Exceptions::ValidationError do |exception|
          puts exception.message
          error_response(message: exception.message, status: 400)
        end

        rescue_from :all do |exception|
          # Print full stack trace for unexpected error
          puts exception.class.name, exception.message, exception.backtrace

          # Better not to return sensitive error message
          error_response(message: 'Internal Server Error', status: 500)
        end
      end
    end
  end
end
