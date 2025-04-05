class OrderChat < ApplicationRecord
    belongs_to :delivery_order
    belongs_to :user
  
    validates :message, presence: true
  end