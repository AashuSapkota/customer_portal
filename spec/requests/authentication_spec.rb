require 'swagger_helper'

RSpec.describe 'Api::V1::Authentication', type: :request do
  path '/api/v1/login' do
    post 'User login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: ['email', 'password']
      }

      response '200', 'successful login' do
        let(:user) { create(:user) }
        let(:credentials) { { email: user.email, password: user.password } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end

      response '401', 'account locked' do
        let(:user) { create(:user, locked: true) }
        let(:credentials) { { email: user.email, password: user.password } }
        run_test!
      end
    end
  end

  path '/api/v1/signup' do
    post 'User signup' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :signup_params, in: :body, schema: {
        type: :object,
        properties: {
          existing_customer: { type: :boolean },
          tax_id: { type: :string },
          email: { type: :string },
          phone: { type: :string },
          first_name: { type: :string },
          last_name: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string },
          name: { type: :string },
          address: { type: :string },
          city: { type: :string },
          state: { type: :string },
          zip_code: { type: :string },
          country: { type: :string }
        },
        required: ['email', 'password', 'password_confirmation', 'first_name', 'last_name']
      }

      response '201', 'user created (new organization)' do
        let(:signup_params) { attributes_for(:user).merge(attributes_for(:organization)).merge(password_confirmation: 'password123') }
        run_test!
      end

      response '201', 'user created (existing organization)' do
        let(:organization) { create(:organization) }
        let(:signup_params) {
          attributes_for(:user).merge(
            existing_customer: true,
            tax_id: organization.tax_id,
            password_confirmation: 'password123'
          )
        }
        run_test!
      end

      response '404', 'organization not found' do
        let(:signup_params) {
          attributes_for(:user).merge(
            existing_customer: true,
            tax_id: 'invalid',
            password_confirmation: 'password123'
          )
        }
        run_test!
      end

      response '422', 'invalid request' do
        let(:signup_params) { { email: 'invalid' } }
        run_test!
      end
    end
  end
end