class FeatureFlag < ApplicationRecord
    belongs_to :flaggable, polymorphic: true
  
    validates :name, presence: true
  end