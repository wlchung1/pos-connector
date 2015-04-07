require 'active_record'

# ActiveRecord does not really well work with namespace for table inheritance.
# Hence, remove namespace from all models
#module POSConnector
#  module Models

# Optimistic locking should be implemented by having a lock_version column.
# Same for other models...
class Job < ActiveRecord::Base
  FLOW_TYPE_RECEIVE_ORDERS_FROM_VEND_JOB = 'ReceiveOrdersFromVendJob'
  FLOW_TYPE_SEND_ORDERS_TO_QUICKBOOKS_JOB = 'SendOrdersToQuickbooksJob'
  STATUS_WAITING = 'Waiting'
  STATUS_RUNNING = 'Running'
  STATUS_SUCCEEDED = 'Succeeded'
  STATUS_FAILED = 'Failed'

  # Single table inheritance is used here. Multiple table inheritance can be more flexible.
  self.inheritance_column = :flow_type

  validates :status, presence: true
  validates_inclusion_of :status, :in => [STATUS_WAITING, STATUS_RUNNING, STATUS_SUCCEEDED, STATUS_FAILED]

  # Inheritance column is excluded when a model object is being converted to JSON.
  # This method is created to add flow_type back in JSON.
  # https://github.com/rails/rails/issues/3508
  def serializable_hash options=nil
    super.merge "flow_type" => flow_type
  end

  def run
  end
end

#  end
#end

require_relative 'receive_orders_from_vend_job'
require_relative 'send_orders_to_quickbooks_job'
