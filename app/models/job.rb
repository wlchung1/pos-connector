require 'active_record'

module POSConnector
  module Models
    class Job < ActiveRecord::Base
      FLOW_TYPE_RECEIVE_ORDERS_FROM_VEND = 'ReceiveOrdersFromVend'
      FLOW_TYPE_SEND_ORDERS_TO_VEND = 'SendOrdersToVend'
      STATUS_RUNNING = 'Running'
      STATUS_SUCCEEDED = 'Succeeded'
      STATUS_FAILED = 'Failed'

      validates :flow_type, presence: true
      validates_inclusion_of :flow_type, :in => [FLOW_TYPE_RECEIVE_ORDERS_FROM_VEND, FLOW_TYPE_SEND_ORDERS_TO_VEND]
      validates :status, presence: true
      validates_inclusion_of :status, :in => [STATUS_RUNNING, STATUS_SUCCEEDED, STATUS_FAILED]
    end
  end
end
