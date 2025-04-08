module Api::V1
    class BranchesController < ApplicationController
      before_action :set_branch, only: [:show, :update, :destroy]
  
      def index
        @branches = current_user.organization.branches
        render json: @branches, include: [:trucks, :storages]
      end
  
      def show
        render json: @branch, include: [:trucks, :storages]
      end
  
      def create
        @branch = current_user.organization.branches.new(branch_params)
        
        if @branch.save
          render json: @branch, status: :created
        else
          render json: { errors: @branch.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def update
        if @branch.update(branch_params)
          render json: @branch
        else
          render json: { errors: @branch.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def destroy
        @branch.destroy
        head :no_content
      end
  
      private
  
      def set_branch
        @branch = current_user.organization.branches.find(params[:id])
      end
  
      def branch_params
        params.require(:branch).permit(
          :name, 
          :address, 
          :city, 
          :state, 
          :zip_code, 
          :country
        )
      end
    end
  end