require 'grape'

module POSConnector
  module API
    class JobsAPI < Grape::API
      resource 'jobs' do
        desc 'Returns all jobs.'
        get do
          POSConnector::Models::Job.all
        end
      end
    end
  end
end
