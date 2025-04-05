class Branch < ApplicationRecord
    belongs_to :organization
    has_many :trucks
    has_many :storages
    has_many :delivery_orders
    has_many :feature_flags, as: :flaggable
  end