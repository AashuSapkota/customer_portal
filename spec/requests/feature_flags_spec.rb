require 'swagger_helper'

RSpec.describe 'Api::V1::FeatureFlags', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:Authorization) { "Bearer #{jwt_encode(user_id: user.id)}" }

  path '/api/v1/feature_flags' do
    get 'List feature flags' do
      tags 'Feature Flags'
      security [Bearer: []]
      produces 'application/json'
      parameter name: :flaggable_type, in: :query, type: :string, required: false
      parameter name: :flaggable_id, in: :query, type: :integer, required: false

      response '200', 'feature flags found (organization level)' do
        let!(:feature_flag) { create(:feature_flag, organization: organization) }
        run_test!
      end

      response '200', 'feature flags found (flaggable level)' do
        let(:branch) { create(:branch, organization: organization) }
        let!(:feature_flag) { create(:feature_flag, flaggable: branch) }
        let(:flaggable_type) { 'Branch' }
        let(:flaggable_id) { branch.id }
        run_test!
      end
    end

    post 'Create a feature flag' do
      tags 'Feature Flags'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :feature_flag, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          enabled: { type: :boolean },
          flaggable_type: { type: :string },
          flaggable_id: { type: :integer }
        },
        required: ['name', 'enabled']
      }

      response '201', 'feature flag created (organization level)' do
        let(:feature_flag) { { name: 'new_feature', enabled: true } }
        run_test!
      end

      response '201', 'feature flag created (flaggable level)' do
        let(:branch) { create(:branch, organization: organization) }
        let(:feature_flag) { { name: 'branch_feature', enabled: true, flaggable_type: 'Branch', flaggable_id: branch.id } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:feature_flag) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/feature_flags/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show a feature flag' do
      tags 'Feature Flags'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'feature flag found' do
        let(:id) { create(:feature_flag, organization: organization).id }
        run_test!
      end

      response '404', 'feature flag not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Update a feature flag' do
      tags 'Feature Flags'
      security [Bearer: []]
      consumes 'application/json'
      parameter name: :feature_flag, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          enabled: { type: :boolean }
        }
      }

      response '200', 'feature flag updated' do
        let(:id) { create(:feature_flag, organization: organization).id }
        let(:feature_flag) { { enabled: false } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { create(:feature_flag, organization: organization).id }
        let(:feature_flag) { { name: '' } }
        run_test!
      end
    end

    delete 'Delete a feature flag' do
      tags 'Feature Flags'
      security [Bearer: []]

      response '204', 'feature flag deleted' do
        let(:id) { create(:feature_flag, organization: organization).id }
        run_test!
      end
    end
  end
end