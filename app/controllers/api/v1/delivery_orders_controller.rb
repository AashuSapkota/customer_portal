module Api::V1
    class DeliveryOrdersController < ApplicationController
      before_action :set_delivery_order, only: [:show, :update, :destroy, :add_document, :add_chat_message]
  
      def index
        @delivery_orders = current_user.organization.delivery_orders
        render json: @delivery_orders, include: [:branch, :vendor, :order_items, :documents]
      end
  
      def show
        render json: @delivery_order, include: [
          :branch, 
          :vendor, 
          { order_items: { include: :product } }, 
          :documents,
          { order_chats: { include: :user } },
          :versions
        ]
      end
  
      def create
        @delivery_order = current_user.organization.delivery_orders.new(delivery_order_params)
        @delivery_order.created_by = current_user
        
        if @delivery_order.save
          process_order_items
          render json: @delivery_order, status: :created
        else
          render json: { errors: @delivery_order.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def update
        if @delivery_order.update(delivery_order_params)
          process_order_items
          render json: @delivery_order
        else
          render json: { errors: @delivery_order.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def destroy
        @delivery_order.destroy
        head :no_content
      end
  
      def add_document
        document = @delivery_order.documents.new(document_params)
        document.uploaded_by = current_user
        
        if document.save
          render json: document, status: :created
        else
          render json: { errors: document.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def add_chat_message
        chat_message = @delivery_order.order_chats.new(chat_params)
        chat_message.user = current_user
        
        if chat_message.save
          render json: chat_message, status: :created
        else
          render json: { errors: chat_message.errors.full_messages }, status: :unprocessable_entity
        end
      end
  
      def export
        @delivery_orders = current_user.organization.delivery_orders
        respond_to do |format|
          format.xlsx {
            response.headers['Content-Disposition'] = 'attachment; filename="delivery_orders.xlsx"'
          }
        end
      end
  
      private
  
      def set_delivery_order
        @delivery_order = current_user.organization.delivery_orders.find(params[:id])
      end
  
      def delivery_order_params
        params.require(:delivery_order).permit(
          :branch_id, 
          :vendor_id, 
          :delivery_date, 
          :status, 
          :delivery_instructions,
          order_items_attributes: [:id, :product_id, :quantity, :price_per_unit, :unit, :notes, :_destroy]
        )
      end
  
      def document_params
        params.require(:document).permit(:file, :document_type, :original_filename, :content_type)
      end
  
      def chat_params
        params.require(:order_chat).permit(:message)
      end
  
      def process_order_items
        return unless params[:delivery_order][:order_items_attributes]
  
        params[:delivery_order][:order_items_attributes].each do |item_params|
          if item_params[:_destroy] == '1' && item_params[:id].present?
            OrderItem.find(item_params[:id]).destroy
          elsif item_params[:id].present?
            item = OrderItem.find(item_params[:id])
            item.update(item_params.except(:_destroy))
          else
            @delivery_order.order_items.create(item_params.except(:_destroy))
          end
        end
      end
    end
  end