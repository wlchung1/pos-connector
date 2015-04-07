require 'grape'
require 'json'

require_relative '../models/job'

module POSConnector
  module API
    class JobsAPI < Grape::API
      resource 'jobs' do
        desc 'Returns all jobs.'
        get do
          Job.all
        end

        desc 'Creates job.'
        params do
          requires :flow_type, type: String
          optional :parameters, type: String
        end
        post do
          Job.create!(
            :flow_type => params[:flow_type],
            :parameters => params[:parameters],
            :status => Job::STATUS_WAITING)
        end

        desc 'Returns job.'
        get ':id' do
          Job.find params[:id]
        end

        desc 'Updates job.'
        params do
          requires :id, type: Integer
          optional :status, type: String
          optional :context, type: String

          at_least_one_of :status, :context
        end
        put ':id' do
          job = Job.find(params[:id])

          if params[:status].to_s != ''
            # Basically it is only valid to change the status to Waiting by the frontend
            if params[:status] == Job::STATUS_WAITING
              if job.status == Job::STATUS_RUNNING
                raise POSConnector::Exceptions::ValidationError, "Cannot rerun a job while it is running"
              end

              job.status = Job::STATUS_WAITING
            else
              raise POSConnector::Exceptions::ValidationError, "Cannot change the job status to #{params[:status]}"
            end
          end

          job.context = params[:context]

          job.save!

          job
        end
      end
    end
  end
end
