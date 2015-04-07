require 'active_record'

class Order < ActiveRecord::Base
  SOURCE_VEND = 'Vend'
  QUICKBOOKS_SYNC_STATUS_NOT_STARTED = 'NotStarted'
  QUICKBOOKS_SYNC_STATUS_SUCCEEDED = 'Succeeded'
  QUICKBOOKS_SYNC_STATUS_FAILED = 'Failed'
  QUICKBOOKS_SYNC_STATUS_STALE = 'Stale'

  validates_inclusion_of :source, :in => [SOURCE_VEND]
  validates_inclusion_of :quickbooks_sync_status, :in => [QUICKBOOKS_SYNC_STATUS_NOT_STARTED,
    QUICKBOOKS_SYNC_STATUS_SUCCEEDED, QUICKBOOKS_SYNC_STATUS_FAILED, QUICKBOOKS_SYNC_STATUS_STALE]
end
