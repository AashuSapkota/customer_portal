class OrderItem < ApplicationRecord
    belongs_to :delivery_order
    belongs_to :product
  
    validates :quantity, numericality: { greater_than: 0 }
    validates :price_per_unit, numericality: { greater_than_or_equal_to: 0 }
  end