module Api::V1
    class ThirdPartyIntegrationsController < ApplicationController
      before_action :set_integration, only: [:show, :update, :destroy, :sync]
  
      def index
        @integrations = current_user.organization.third_party_integrations
        render json: @integrations
      end
  
      def show
        render json: @integration, include: [:sync_logs]
      end
  
      def create
        @integration = current_user.organization.third_party_integrations.new(integration_params)
        
        if @integration.save
          render json: @integration, status: :created
        else
          render json: { errors: @integration.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def update
        if @integration.update(integration_params)
          render json: @integration
        else
          render json: { errors: @integration.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def destroy
        @integration.destroy
        head :no_content
      end
  
      def sync
        syncable_type = params[:syncable_type]
        syncable_id = params[:syncable_id]
        
        if syncable_type && syncable_id
          syncable = syncable_type.constantize.find(syncable_id)
          SyncWithThirdPartyJob.perform_later(@integration.id, syncable.class.name, syncable.id)
          render json: { message: 'Sync initiated' }
        else
          render json: { error: 'syncable_type and syncable_id are required' }, status: :bad_request
        end
      end
  
      private
  
      def set_integration
        @integration = current_user.organization.third_party_integrations.find(params[:id])
      end
  
      def integration_params
        params.require(:third_party_integration).permit(
          :name, 
          :api_key, 
          :api_secret, 
          :base_url, 
          :active
        )
      end
    end
  end