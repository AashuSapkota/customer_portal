class User < ApplicationRecord
    has_secure_password
    has_many :login_histories
    has_many :user_roles
    has_many :roles, through: :user_roles
    has_many :created_orders, class_name: 'DeliveryOrder', foreign_key: 'created_by_id'
    has_many :order_chats
    has_many :uploaded_documents, class_name: 'Document', foreign_key: 'uploaded_by_id'
    belongs_to :organization, optional: true
  
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :phone, presence: true, format: { with: /\A\+?[\d\s\-]+\z/ }
    validates :first_name, :last_name, presence: true
  
    def full_name
      "#{first_name} #{last_name}"
    end
  
    def track_login(request)
      login_histories.create!(
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        login_at: Time.current
      )
      update(last_seen_at: Time.current)
    end
  
    def lock_account!
      update(locked_at: Time.current)
    end
  
    def unlock_account!
      update(locked_at: nil, failed_login_attempts: 0)
    end
  
    def locked?
      locked_at.present? && locked_at > 1.hour.ago
    end
  
    def increment_failed_attempts
      update(failed_login_attempts: failed_login_attempts + 1)
      lock_account! if failed_login_attempts >= 5
    end
  
    def has_role?(role_name)
      roles.exists?(name: role_name)
    end
  end
  
  