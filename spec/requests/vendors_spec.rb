require 'swagger_helper'

RSpec.describe 'Api::V1::Vendors', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:Authorization) { "Bearer #{jwt_encode(user_id: user.id)}" }

  path '/api/v1/vendors' do
    get 'List vendors' do
      tags 'Vendors'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'vendors found' do
        let!(:vendor) { create(:vendor, organization: organization) }
        run_test!
      end
    end

    post 'Create a vendor' do
      tags 'Vendors'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :vendor, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          contact_email: { type: :string },
          contact_phone: { type: :string },
          address: { type: :string },
          city: { type: :string },
          state: { type: :string },
          zip_code: { type: :string },
          country: { type: :string }
        },
        required: ['name']
      }

      response '201', 'vendor created' do
        let(:vendor) { { name: 'New Vendor', contact_email: 'vendor@example.com' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:vendor) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/vendors/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show a vendor' do
      tags 'Vendors'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'vendor found' do
        let(:id) { create(:vendor, organization: organization).id }
        run_test!
      end

      response '404', 'vendor not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Update a vendor' do
      tags 'Vendors'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :vendor, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          contact_email: { type: :string }
        }
      }

      response '200', 'vendor updated' do
        let(:id) { create(:vendor, organization: organization).id }
        let(:vendor) { { name: 'Updated Vendor Name' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { create(:vendor, organization: organization).id }
        let(:vendor) { { name: '' } }
        run_test!
      end
    end

    delete 'Delete a vendor' do
      tags 'Vendors'
      security [Bearer: []]

      response '204', 'vendor deleted' do
        let(:id) { create(:vendor, organization: organization).id }
        run_test!
      end
    end
  end

  path '/api/v1/vendors/{id}/set_preferred' do
    parameter name: :id, in: :path, type: :string

    post 'Set vendor as preferred' do
      tags 'Vendors'
      security [Bearer: []]

      response '200', 'vendor set as preferred' do
        let(:id) { create(:vendor, organization: organization).id }
        run_test!
      end
    end
  end
end