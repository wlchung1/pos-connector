require 'grape'

require_relative '../models/order'

module POSConnector
  module API
    class OrdersAPI < Grape::API
      resource 'orders' do
        desc 'Returns order.'
        get ':id' do
          Order.find params[:id]
        end

        desc 'Returns all orders.'
        get do
          Order.all
        end
      end
    end
  end
end
