require 'swagger_helper'

RSpec.describe 'Api::V1::Contracts', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:vendor) { create(:vendor, organization: organization) }
  let(:Authorization) { "Bearer #{jwt_encode(user_id: user.id)}" }

  path '/api/v1/contracts' do
    get 'List contracts' do
      tags 'Contracts'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'contracts found' do
        let!(:contract) { create(:contract, organization: organization, vendor: vendor) }
        run_test!
      end
    end

    post 'Create a contract' do
      tags 'Contracts'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :contract, in: :body, schema: {
        type: :object,
        properties: {
          vendor_id: { type: :integer },
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date },
          terms: { type: :string }
        },
        required: ['vendor_id', 'start_date']
      }

      response '201', 'contract created' do
        let(:contract) { { vendor_id: vendor.id, start_date: Date.today.to_s } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:contract) { { vendor_id: nil } }
        run_test!
      end
    end
  end

  path '/api/v1/contracts/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show a contract' do
      tags 'Contracts'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'contract found' do
        let(:id) { create(:contract, organization: organization, vendor: vendor).id }
        run_test!
      end

      response '404', 'contract not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Update a contract' do
      tags 'Contracts'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :contract, in: :body, schema: {
        type: :object,
        properties: {
          vendor_id: { type: :integer },
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date },
          terms: { type: :string }
        }
      }

      response '200', 'contract updated' do
        let(:id) { create(:contract, organization: organization, vendor: vendor).id }
        let(:contract) { { terms: 'Updated terms' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { create(:contract, organization: organization, vendor: vendor).id }
        let(:contract) { { vendor_id: nil } }
        run_test!
      end
    end

    delete 'Delete a contract' do
      tags 'Contracts'
      security [Bearer: []]

      response '204', 'contract deleted' do
        let(:id) { create(:contract, organization: organization, vendor: vendor).id }
        run_test!
      end
    end
  end

  path '/api/v1/contracts/{id}/sign' do
    parameter name: :id, in: :path, type: :string

    post 'Sign a contract' do
      tags 'Contracts'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :signature, in: :body, schema: {
        type: :object,
        properties: {
          signed_by: { type: :string },
          signature: { type: :string }
        },
        required: ['signed_by', 'signature']
      }

      response '200', 'contract signed' do
        let(:id) { create(:contract, organization: organization, vendor: vendor).id }
        let(:signature) { { signed_by: 'John Doe', signature: 'base64encodedimage' } }
        run_test!
      end

      response '422', 'invalid signature' do
        let(:id) { create(:contract, organization: organization, vendor: vendor).id }
        let(:signature) { { signed_by: '' } }
        run_test!
      end
    end
  end
end