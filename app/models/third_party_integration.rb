class ThirdPartyIntegration < ApplicationRecord
    belongs_to :organization
    has_many :sync_logs
  
    validates :name, presence: true
    validates :base_url, presence: true
  end