require 'swagger_helper'

RSpec.describe 'Api::V1::Branches', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }

  path '/api/v1/branches' do
    get 'List branches' do
      tags 'Branches'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'branches found' do
        let!(:branch) { create(:branch, organization: organization) }
        run_test!
      end
    end

    post 'Create a branch' do
      tags 'Branches'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :branch, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          address: { type: :string },
          city: { type: :string },
          state: { type: :string },
          zip_code: { type: :string },
          country: { type: :string }
        },
        required: ['name', 'address']
      }

      response '201', 'branch created' do
        let(:branch) { { name: 'Main Branch', address: '123 Main St' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:branch) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/branches/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show a branch' do
      tags 'Branches'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'branch found' do
        let(:id) { create(:branch, organization: organization).id }
        run_test!
      end

      response '404', 'branch not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Update a branch' do
      tags 'Branches'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :branch, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          address: { type: :string }
        }
      }

      response '200', 'branch updated' do
        let(:id) { create(:branch, organization: organization).id }
        let(:branch) { { name: 'Updated Name' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { create(:branch, organization: organization).id }
        let(:branch) { { name: '' } }
        run_test!
      end
    end

    delete 'Delete a branch' do
      tags 'Branches'
      security [Bearer: []]

      response '204', 'branch deleted' do
        let(:id) { create(:branch, organization: organization).id }
        run_test!
      end
    end
  end
end