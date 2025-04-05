class SyncLog < ApplicationRecord
    belongs_to :third_party_integration
    belongs_to :syncable, polymorphic: true
  
    enum status: {
      pending: 'pending',
      success: 'success',
      failed: 'failed'
    }
  end