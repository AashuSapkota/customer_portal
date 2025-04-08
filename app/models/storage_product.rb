class StorageProduct < ApplicationRecord
    belongs_to :storage
    belongs_to :product
  end