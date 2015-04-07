require_relative 'config/environment'

# Configure API
require_relative 'app/main'

run POSConnector::Main.instance
