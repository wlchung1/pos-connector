module POSConnector
  module Vend
    class ErrorParser
      def self.response_has_errors?(response)
        response.code == 400 || response.code == 401 || !response['status'].nil?
      end
    end
  end
end