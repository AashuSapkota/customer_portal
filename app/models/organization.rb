class Organization < ApplicationRecord
    has_many :users
    has_many :branches
    has_many :vendors
    has_many :contracts
    has_many :delivery_orders, through: :branches
    has_many :feature_flags, as: :flaggable
  end