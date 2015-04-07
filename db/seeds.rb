require_relative '../app/models/vend_account'
require_relative '../app/models/quickbooks_account'

# Create the default Vend account
if VendAccount.find_by(:id => 1).nil?
  VendAccount.create! :id => 1
end

# Create the default Quickbooks account
if QuickbooksAccount.find_by(:id => 1).nil?
  QuickbooksAccount.create!(
    :id => 1,
    :account_name => "Other Income",
    :payment_method_map => "[{\"Cash\": \"Cash\", \"American Express\": \"American Express\", \"Visa\": \"Visa\", \"MasterCard\": \"MasterCard\", \"Credit Card\": \"American Express\", \"None\": \"Cash\"}]")
end
