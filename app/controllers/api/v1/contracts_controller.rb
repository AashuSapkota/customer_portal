module Api::V1
    class ContractsController < ApplicationController
      before_action :set_contract, only: [:show, :update, :destroy, :sign]
  
      def index
        @contracts = current_user.organization.contracts
        render json: @contracts
      end
  
      def show
        render json: @contract
      end
  
      def create
        @contract = current_user.organization.contracts.new(contract_params)
        
        if @contract.save
          render json: @contract, status: :created
        else
          render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def update
        if @contract.update(contract_params)
          render json: @contract
        else
          render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def destroy
        @contract.destroy
        head :no_content
      end
  
      def sign
        if @contract.update(
          signed_by: params[:signed_by],
          signed_at: Time.current,
          signature: params[:signature],
          status: 'signed'
        )
          render json: @contract
        else
          render json: { errors: @contract.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      private
  
      def set_contract
        @contract = current_user.organization.contracts.find(params[:id])
      end
  
      def contract_params
        params.require(:contract).permit(
          :vendor_id, 
          :start_date, 
          :end_date, 
          :terms
        )
      end
    end
  end