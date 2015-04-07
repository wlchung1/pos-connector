require 'rufus-scheduler'

require_relative 'config/environment'
require_relative 'app/job_runner'

job_scheduler = Rufus::Scheduler.new
job_runner = POSConnector::JobRunner.new

# Start 1 worker, polling for jobs for every 10 seconds
# To-Do: Make use of message system, such as RabbitMQ or Resque
job_scheduler.every '10s', :overlap => false do
  puts "Triggering job runner..."
  job_runner.run_jobs
end

at_exit do
  job_scheduler.shutdown(:wait)
end

job_scheduler.join
