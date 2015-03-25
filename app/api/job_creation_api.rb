require 'grape'

require_relative '../exceptions/validation_error'
require_relative '../services/job_service'

module POSConnector
  module API
    class JobCreationAPI < Grape::API
      resource 'job-creation' do
        desc 'Creates job.'
        post ':flow_type' do
          job_service = POSConnector::Services::JobService.new

          case params[:flow_type]
          when POSConnector::Models::Job::FLOW_TYPE_RECEIVE_ORDERS_FROM_VEND
            job_service.create_receive_orders_from_vend_job params
          else
            raise POSConnector::Exceptions::ValidationError, "#{params[:flow_type]} is an invalid flow type"
          end
        end
      end
    end
  end
end
