# Setup
Run "bundle install"

Run "rake db:setup"

# Run
Run "rackup"

The POS Connector website will be up at http://localhost:9292/

# User Guide
1. Click "Vend Account" on the top right hand corner.
2. Click "Edit" and you can input credentials for connecting to Vend Account.  Leave blank to retrieve all orders in the first order polling.
3. Click "Orders" in the top menu.
4. Click "Poll Orders" to submit a order polling job.
5. It depends on how many orders to be retrieved from Vend.  Usually, after 10 seconds, you will see a "Poll orders job completed" notification.
6. Click "Refresh" to see the retrieved orders.
7. You may also go to the "Jobs" page to check the statuses of the jobs.
