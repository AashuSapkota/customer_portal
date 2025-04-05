module Api::V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request, only: [:login, :signup]
      skip_before_action :check_rate_limit, only: [:login, :signup]
  
      def login
        puts "here"
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          if user.locked?
            render json: { error: 'Account locked. Please contact support.' }, status: :unauthorized
          else
            user.track_login(request)
            token = jwt_encode(user_id: user.id)
            render json: { token: token, user: user.as_json(except: [:password_digest]) }
          end
        else
          user&.increment_failed_attempts
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
  
      def signup
        if params[:existing_customer] == 'true'
          organization = Organization.find_by(tax_id: params[:tax_id])
          if organization
            user = organization.users.new(user_params)
            if user.save
              token = jwt_encode(user_id: user.id)
              render json: { token: token, user: user.as_json(except: [:password_digest]) }, status: :created
            else
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { error: 'Organization not found with provided tax ID' }, status: :not_found
          end
        else
          organization = Organization.new(organization_params)
          if organization.save
            user = organization.users.new(user_params)
            if user.save
              token = jwt_encode(user_id: user.id)
              render json: { token: token, user: user.as_json(except: [:password_digest]) }, status: :created
            else
              organization.destroy
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { errors: organization.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
  
      private
  
      def user_params
        params.permit(:email, :phone, :first_name, :last_name, :password, :password_confirmation)
      end
  
      def organization_params
        params.permit(:name, :tax_id, :address, :city, :state, :zip_code, :country)
      end
    end
  end