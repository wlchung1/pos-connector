# Setup
Run "gem install bundler"

Run "bundle install"

Run "rake db:setup"

# Run
Open a terminal and run "rackup"

Open another terminal and run "ruby job_scheduler.rb"

The POS Connector website will be up at http://localhost:9292/

# User Guide
## Setup Vend Account
1. Click "Vend Account" in the menu on the top right hand corner.
2. Click "Edit" and you can then input credentials for connecting to your Vend account.  Leave blank to retrieve all orders in the first order polling.

## Setup Quickbooks Account
1. Click "Quickbooks Account" in the menu on the top right hand corner.
2. Click "Connect to Quickbooks" and a new window will be popped-up.  If not, please configure the browser to allow pop-up window.
3. It will then redirect to Quickbooks and ask you to log on.  As it is just a testing application, it can only connect to a Quickbooks sandbox company.  Please log on to Quickbooks with a develop account who has sandbox company.

## Poll Orders from Vend
1. Click "Orders" in the top menu.
2. Click "Poll Orders from Vend" to submit an order polling job.
3. You can check the status of the job in the Jobs page by clicking "Jobs" in the top menu.
4. The time required for the job depends on how many orders to be retrieved from Vend.  Usually, after 30 seconds, the job will be completed and the status will become "Succeeded".
5. Click "Orders" in the top menu and you should be able to see the orders retrieved from Vend.

## Send Orders to Quickbooks
1. Click "Orders" in the top menu.
2. Check the orders that you want to send to Quickbooks on the leftmost column.
3. Click "Send Orders to Quickbooks" to submit an order sending job.
4. You can check the status of the job in the Jobs page by clicking "Jobs" in the top menu.
5. The time required for the job depends on how many orders to be sent to Quickbooks.  Usually, after 30 seconds, the job will be completed and the status will become "Succeeded".
6. Click "Orders" in the top menu and the Quickbooks Sync Statuses of the sent orders should become "Succeeded".

## Rerun a job
1. Click "Jobs" in the top menu.
2. Click "Edit" for the job that you want to rerun.
3. Modify the message in the "Context" field to fix any error in the last run.
4. Check the "Rerun" checkbox.
5. Click "Save".
6. The job will then be rerun by the job scheduler.

# To-Do
1. Only jobs_api.rb currently has test covered.  Add RSpec tests for the other classes/modules.
2. Database is not really suitable for implementing background jobs.  Use messaging system such as RabbitMQ or Resque instead.
3. Use multiple table inheritance (MTI) instead of single table inheritance for job.  MTI allows us to define different fields for different jobs.
