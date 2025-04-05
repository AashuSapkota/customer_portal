class Storage < ApplicationRecord
    belongs_to :branch
    has_many :storage_products
    has_many :products, through: :storage_products
end