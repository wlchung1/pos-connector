require 'grape'

require_relative '../models/order'

module POSConnector
  module API
    class OrdersAPI < Grape::API
      resource 'orders' do
        desc 'Returns order.'
        get ':id' do
          POSConnector::Models::Order.find(params[:id])
        end

        desc 'Returns all orders.'
        get do
          POSConnector::Models::Order.all
        end
      end
    end
  end
end
