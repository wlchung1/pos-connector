require 'json'
require 'rack/test'
require 'rspec'
require 'spec_helper'

require_relative '../../app/api/api'
require_relative '../../app/models/job'

RSpec.describe 'POSConnector::API::JobsAPI' do
  include Rack::Test::Methods

  def app
    POSConnector::API::API
  end

  def validate_job(actual_job_hash, expected_job)
    expect(actual_job_hash['id']).to eq(expected_job.id)
    expect(actual_job_hash['flow_type']).to eq(expected_job.flow_type)
    expect(actual_job_hash['parameters']).to eq(expected_job.parameters)
    expect(actual_job_hash['status']).to eq(expected_job.status)
    expect(actual_job_hash['context']).to eq(expected_job.context)
    expect(actual_job_hash['error_message']).to eq(expected_job.error_message)
  end

  def get_non_existing_job_id
    # Generate an ID of which the job does not exist
    id = 0
    @jobs_array.each { |job| id += job.id }
    id
  end
  
  before :each do
    @running_job = Job.create!(
        :flow_type => Job::FLOW_TYPE_RECEIVE_ORDERS_FROM_VEND_JOB,
        :status => Job::STATUS_RUNNING,
        :start_datetime => Time.new)

    @succeeded_job = Job.create!(
        :flow_type => Job::FLOW_TYPE_SEND_ORDERS_TO_QUICKBOOKS_JOB,
        :parameters => '{"ids":[10,11]}',
        :status => Job::STATUS_SUCCEEDED,
        :start_datetime => Time.new,
        :end_datetime => Time.new + 20,
        :context => '{"10":{"id":"918db148-f4ec-af9f-11e4-dc796ef86a41"},"11":{"id":"918db148-f4ec-af9f-11e4-dc79671c1255""}}')

    @failed_job = Job.create!(
        :flow_type => Job::FLOW_TYPE_SEND_ORDERS_TO_QUICKBOOKS_JOB,
        :parameters => '{"ids":[10,15,18,20,30]}',
        :status => Job::STATUS_FAILED,
        :start_datetime => Time.new,
        :end_datetime => Time.new + 5,
        :error_message => 'Realm ID Not Configured')

    @jobs_array = [@running_job, @succeeded_job, @failed_job]
    @jobs_hash = {}
    @jobs_array.each { |job| @jobs_hash[job.id] = job }
  end

  describe 'get jobs' do
    context 'with existing jobs' do
      it 'returns all existing jobs' do
        get '/api/jobs'

        returned_jobs = JSON.parse(last_response.body)

        expect(returned_jobs.length).to eq(@jobs_array.length)

        returned_jobs.each do |returned_job|
          job = @jobs_hash[returned_job['id']]

          expect(job).not_to be_nil, "unexpected job #{returned_job['id']} returned"

          validate_job returned_job, job
        end
        expect(last_response.status).to eq(200)
      end
    end

    context 'with no existing jobs' do
      it 'returns no jobs' do
        Job.delete_all

        get '/api/jobs'
        expect(last_response.body).to eq('[]')
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe 'post jobs' do
    context 'when parameters are valid' do
      it 'returns the created job' do
        flow_type = Job::FLOW_TYPE_SEND_ORDERS_TO_QUICKBOOKS_JOB
        parameters = '{"ids":[10,15,18,20,30]}'

        post '/api/jobs', :flow_type => flow_type, :parameters => parameters

        returned_job = JSON.parse(last_response.body)

        created_job = Job.find(returned_job['id'])

        # Validate the persisted job
        expect(created_job.flow_type).to eq(Job::FLOW_TYPE_SEND_ORDERS_TO_QUICKBOOKS_JOB)
        expect(created_job.parameters).to eq(parameters)
        expect(created_job.status).to eq(Job::STATUS_WAITING)
        expect(created_job.context).to be_nil
        expect(created_job.error_message).to be_nil
        expect(created_job.start_datetime).to be_nil
        expect(created_job.end_datetime).to be_nil

        # Validate the correct job is returned
        validate_job returned_job, created_job
        expect(last_response.status).to eq(201)
      end
    end

    context 'when the specified flow type is invalid' do
      it 'does not create the job and returns 500 as the status code' do
        post '/api/jobs', :flow_type => 'InvalidJob'

        # Make sure that the job is not persisted        
        expect(Job.all.length).to eq(@jobs_array.length)

        expect(last_response.status).to eq(500)
      end
    end
  end

  describe 'get jobs/:id' do
    context 'when the specified job ID exists' do
      it 'returns the job with the specified ID' do
        get "/api/jobs/#{@succeeded_job.id}"
        validate_job JSON.parse(last_response.body), @succeeded_job
        expect(last_response.status).to eq(200)
      end
    end

    context 'when the specified job ID does not exist' do
      it 'returns 404 as the status code' do
        id = get_non_existing_job_id

        get "/api/jobs/#{id}"
        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'put jobs/:id' do
    context 'when parameters are valid' do
      it 'returns the updated job' do
        id = @succeeded_job.id
        status = Job::STATUS_WAITING
        context = '{"10":{"id":"918db148-f4ec-af9f-11e4-dc796ef86a41","status":"CLOSED"}}'

        put "/api/jobs/#{id}", :status => status, :context => context

        updated_job = Job.find(id)

        # Validate the persisted job
        expect(updated_job.status).to eq(status)
        expect(updated_job.context).to eq(context)

        validate_job JSON.parse(last_response.body), updated_job
        expect(last_response.status).to eq(200)
      end
    end

    context 'when the specified job ID does not exist' do
      it 'returns 404 as the status code' do
        id = get_non_existing_job_id
        status = Job::STATUS_WAITING
        context = '{"10":{"id":"918db148-f4ec-af9f-11e4-dc796ef86a41","status":"CLOSED"}}'

        put "/api/jobs/#{id}", :status => status, :context => context
        expect(last_response.status).to eq(404)
      end
    end

    context 'when it attempts to change the job status from running to waiting' do
      it 'does not change the job status and returns 400 as the status code' do
        id = @running_job.id
        status = Job::STATUS_WAITING
        context = '{"10":{"id":"918db148-f4ec-af9f-11e4-dc796ef86a41","status":"CLOSED"}}'

        put "/api/jobs/#{id}", :status => status, :context => context

        job = Job.find(id)
        expect(job.status).to eq(Job::STATUS_RUNNING)

        expect(last_response.status).to eq(400)
      end
    end

    context 'when it attempts to change the job status from to status other than waiting' do
      it 'does not change the job status and returns 400 as the status code' do
        id = @succeeded_job.id
        status = Job::STATUS_FAILED
        context = '{"10":{"id":"918db148-f4ec-af9f-11e4-dc796ef86a41","status":"CLOSED"}}'

        put "/api/jobs/#{id}", :status => status, :context => context

        job = Job.find(id)
        expect(job.status).to eq(Job::STATUS_SUCCEEDED)

        expect(last_response.status).to eq(400)
      end
    end

    context 'when no parameters are specified' do
      it 'returns 400 as the status code' do
        put "/api/jobs/#{@succeeded_job.id}"

        expect(last_response.status).to eq(400)
      end
    end
  end
end
