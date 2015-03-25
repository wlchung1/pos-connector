require_relative '../app/models/vend_account'

# Create the default Vend account
POSConnector::Models::VendAccount.create!(:id => 1)
