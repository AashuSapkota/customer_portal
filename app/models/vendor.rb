class Vendor < ApplicationRecord
    belongs_to :organization
    has_many :delivery_orders
    has_many :contracts
  end