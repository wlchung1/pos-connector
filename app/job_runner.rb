require 'json'

require_relative 'models/job'
require_relative 'vend/client'
require_relative 'vend/vend_endpoint_error'
require_relative 'exceptions/validation_error'

module POSConnector
  class JobRunner
    def initialize(vend_client_class = POSConnector::Vend::Client)
      @vend_client_class = vend_client_class
    end

    # To-Do: A message system, such as RabbitMQ or Resque,
    # would be a better fit for implementing job queue and background job.
    def lock_job
      job = Job.where(:status => Job::STATUS_WAITING).first
      update_count = 0

      while update_count == 0 && !job.nil? do
        update_count = Job.where(:id => job.id, :status => Job::STATUS_WAITING).update_all(
          :status => Job::STATUS_RUNNING,
          :start_datetime => Time.new,
          :end_datetime => nil,
          :error_message => nil)

        if update_count > 0
          # As the job was just updated, it is necessary to retrieve a up-to-date version here.
          job = Job.find(job.id)
        else
          # Job was picked up by another worker.
          # Trying to pick another one.
          job = Job.where(:status => Job::STATUS_WAITING).first
        end
      end

      if update_count > 0
        job
      else
        nil
      end
    end

    def run_jobs
      job = lock_job

      while !job.nil? do
        begin
          puts "Running #{job.flow_type} #{job.id}"

          job.run

          # Job succeeded if it arrives here
          job.status = Job::STATUS_SUCCEEDED
        rescue Exception => exception
          puts "Job #{job.id} failed: #{exception.class.name} - #{exception.message}"

          job.status = Job::STATUS_FAILED
          if (exception.instance_of? POSConnector::Exceptions::ValidationError) || (exception.instance_of? POSConnector::Exceptions::JobError)
            # Known error and thus set the message.
            job.error_message = exception.message
          elsif exception.instance_of? StandardError
            job.error_message = 'Internal Server Error'
          else
            job.error_message = 'Internal Server Error'

            # If it is not a standard error, it may be a fatal error such that it is impossible to try any other jobs.
            # Therefore, re-raise the exception.
            raise exception
          end
        ensure
          job.end_datetime = Time.now
          job.save!

          puts "#{job.flow_type} #{job.id} finished"
        end

        job = lock_job
      end
    end
  end
end
