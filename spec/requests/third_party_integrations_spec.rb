require 'swagger_helper'

RSpec.describe 'Api::V1::ThirdPartyIntegrations', type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:Authorization) { "Bearer #{jwt_encode(user_id: user.id)}" }

  path '/api/v1/third_party_integrations' do
    get 'List integrations' do
      tags 'Third Party Integrations'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'integrations found' do
        run_test!
      end
    end
  end
end