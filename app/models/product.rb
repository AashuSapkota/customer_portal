class Product < ApplicationRecord
    has_many :storage_products
    has_many :storages, through: :storage_products
    has_many :order_items
  end