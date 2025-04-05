require 'swagger_helper'

RSpec.describe 'Api::V1::DeliveryOrders', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:branch) { create(:branch, organization: organization) }
  let(:vendor) { create(:vendor) }
  let(:product) { create(:product) }
  let(:Authorization) { "Bearer #{jwt_encode(user_id: user.id)}" }

  path '/api/v1/delivery_orders' do
    get 'List delivery orders' do
      tags 'Delivery Orders'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'delivery orders found' do
        let!(:delivery_order) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor) }
        run_test!
      end
    end

    post 'Create a delivery order' do
      tags 'Delivery Orders'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :delivery_order, in: :body, schema: {
        type: :object,
        properties: {
          branch_id: { type: :integer },
          vendor_id: { type: :integer },
          delivery_date: { type: :string, format: :date },
          status: { type: :string },
          delivery_instructions: { type: :string },
          order_items_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer },
                quantity: { type: :number },
                price_per_unit: { type: :number },
                unit: { type: :string },
                notes: { type: :string }
              },
              required: ['product_id', 'quantity']
            }
          }
        },
        required: ['branch_id', 'vendor_id', 'delivery_date']
      }

      response '201', 'delivery order created' do
        let(:delivery_order) {
          {
            branch_id: branch.id,
            vendor_id: vendor.id,
            delivery_date: Date.tomorrow.to_s,
            order_items_attributes: [{
                                       product_id: product.id,
                                       quantity: 10,
                                       unit: 'kg'
                                     }]
          }
        }
        run_test!
      end

      response '422', 'invalid request' do
        let(:delivery_order) { { branch_id: nil } }
        run_test!
      end
    end
  end

  path '/api/v1/delivery_orders/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show a delivery order' do
      tags 'Delivery Orders'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'delivery order found' do
        let(:id) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor).id }
        run_test!
      end

      response '404', 'delivery order not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Update a delivery order' do
      tags 'Delivery Orders'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :delivery_order, in: :body, schema: {
        type: :object,
        properties: {
          status: { type: :string },
          delivery_instructions: { type: :string },
          order_items_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                product_id: { type: :integer },
                quantity: { type: :number },
                _destroy: { type: :boolean }
              }
            }
          }
        }
      }

      response '200', 'delivery order updated' do
        let(:order) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor) }
        let(:order_item) { create(:order_item, delivery_order: order) }
        let(:id) { order.id }
        let(:delivery_order) {
          {
            status: 'approved',
            order_items_attributes: [{
                                       id: order_item.id,
                                       quantity: 20
                                     }]
          }
        }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor).id }
        let(:delivery_order) { { status: '' } }
        run_test!
      end
    end

    delete 'Delete a delivery order' do
      tags 'Delivery Orders'
      security [Bearer: []]

      response '204', 'delivery order deleted' do
        let(:id) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor).id }
        run_test!
      end
    end
  end

  path '/api/v1/delivery_orders/{id}/add_document' do
    parameter name: :id, in: :path, type: :string

    post 'Add document to delivery order' do
      tags 'Delivery Orders'
      security [Bearer: []]
      consumes 'multipart/form-data'
      parameter name: :file, in: :formData, type: :file, required: true
      parameter name: :document_type, in: :formData, type: :string

      response '201', 'document added' do
        let(:id) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor).id }
        let(:file) { fixture_file_upload('spec/fixtures/sample.pdf', 'application/pdf') }
        let(:document_type) { 'invoice' }
        run_test!
      end

      response '422', 'invalid document' do
        let(:id) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor).id }
        let(:file) { nil }
        run_test!
      end
    end
  end

  path '/api/v1/delivery_orders/{id}/add_chat_message' do
    parameter name: :id, in: :path, type: :string

    post 'Add chat message to delivery order' do
      tags 'Delivery Orders'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :message, in: :body, schema: {
        type: :object,
        properties: {
          message: { type: :string }
        },
        required: ['message']
      }

      response '201', 'chat message added' do
        let(:id) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor).id }
        let(:message) { { message: 'Hello, when will this be delivered?' } }
        run_test!
      end

      response '422', 'invalid message' do
        let(:id) { create(:delivery_order, organization: organization, branch: branch, vendor: vendor).id }
        let(:message) { { message: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/delivery_orders/export' do
    get 'Export delivery orders' do
      tags 'Delivery Orders'
      security [Bearer: []]
      produces 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      response '200', 'export generated' do
        run_test!
      end
    end
  end
end