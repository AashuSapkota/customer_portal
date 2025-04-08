class DeliveryOrder < ApplicationRecord
  belongs_to :branch
  belongs_to :vendor
  belongs_to :created_by, class_name: 'User'
  has_many :order_items
  has_many :products, through: :order_items
  has_many :order_chats
  has_many :documents, as: :documentable
  has_paper_trail

  validates :order_number, presence: true, uniqueness: true
  validates :delivery_date, presence: true

  before_validation :generate_order_number, on: :create


  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def total_amount
    order_items.sum { |item| item.quantity * item.price_per_unit }
  end
end