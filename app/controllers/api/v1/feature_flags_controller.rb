module Api::V1
    class FeatureFlagsController < ApplicationController
      before_action :set_feature_flag, only: [:show, :update, :destroy]
  
      def index
        @feature_flags = if params[:flaggable_type] && params[:flaggable_id]
          klass = params[:flaggable_type].constantize
          flaggable = klass.find(params[:flaggable_id])
          flaggable.feature_flags
        else
          current_user.organization.feature_flags
        end
        
        render json: @feature_flags
      end
  
      def show
        render json: @feature_flag
      end
  
      def create
        @feature_flag = if params[:flaggable_type] && params[:flaggable_id]
          klass = params[:flaggable_type].constantize
          flaggable = klass.find(params[:flaggable_id])
          flaggable.feature_flags.new(feature_flag_params)
        else
          current_user.organization.feature_flags.new(feature_flag_params)
        end
        
        if @feature_flag.save
          render json: @feature_flag, status: :created
        else
          render json: { errors: @feature_flag.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def update
        if @feature_flag.update(feature_flag_params)
          render json: @feature_flag
        else
          render json: { errors: @feature_flag.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def destroy
        @feature_flag.destroy
        head :no_content
      end
  
      private
  
      def set_feature_flag
        @feature_flag = if params[:flaggable_type] && params[:flaggable_id]
          klass = params[:flaggable_type].constantize
          flaggable = klass.find(params[:flaggable_id])
          flaggable.feature_flags.find(params[:id])
        else
          current_user.organization.feature_flags.find(params[:id])
        end
      end
  
      def feature_flag_params
        params.require(:feature_flag).permit(:name, :enabled)
      end
    end
  end