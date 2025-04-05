class Contract < ApplicationRecord
    belongs_to :organization
    belongs_to :vendor
  
    validates :start_date, :end_date, presence: true
    validate :end_date_after_start_date
  
    def end_date_after_start_date
      return if end_date.blank? || start_date.blank?
  
      if end_date < start_date
        errors.add(:end_date, "must be after the start date")
      end
    end
  
    def signed?
      signed_at.present? && signature.present?
    end
  end