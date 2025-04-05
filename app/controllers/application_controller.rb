class ApplicationController < ActionController::API
  before_action :authenticate_request
  before_action :check_rate_limit

  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    
    begin
      decoded = jwt_decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: 'User not found' }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: 'Invalid token' }, status: :unauthorized
    end
  end

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  end

  def authorize_admin
    unless current_user.has_role?('admin')
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end

  def check_rate_limit
    key = "rate_limit:#{current_user.id}:#{(Time.now.to_i / 60)}"
    count = Rails.cache.fetch(key, expires_in: 1.minute) { 0 }
    
    if count >= 100 # 100 requests per minute
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    else
      Rails.cache.increment(key)
    end
  end
end