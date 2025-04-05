module Api::V1
    class VendorsController < ApplicationController
      before_action :set_vendor, only: [:show, :update, :destroy, :set_preferred]
  
      # GET /api/v1/vendors
      def index
        @vendors = current_user.organization.vendors
        render json: @vendors
      end
  
      # GET /api/v1/vendors/1
      def show
        render json: @vendor, include: [:contracts]
      end
  
      # POST /api/v1/vendors
      def create
        @vendor = current_user.organization.vendors.new(vendor_params)
        
        if @vendor.save
          render json: @vendor, status: :created
        else
          render json: { errors: @vendor.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      # PATCH/PUT /api/v1/vendors/1
      def update
        if @vendor.update(vendor_params)
          render json: @vendor
        else
          render json: { errors: @vendor.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      # DELETE /api/v1/vendors/1
      def destroy
        @vendor.destroy
        head :no_content
      end
  
      # POST /api/v1/vendors/1/set_preferred
      def set_preferred
        current_user.organization.vendors.update_all(preferred: false)
        @vendor.update(preferred: true)
        render json: @vendor
      end
  
      private
  
      def set_vendor
        @vendor = current_user.organization.vendors.find(params[:id])
      end
  
      def vendor_params
        params.require(:vendor).permit(
          :name, 
          :contact_email, 
          :contact_phone, 
          :address, 
          :city, 
          :state, 
          :zip_code, 
          :country
        )
      end
    end
  end