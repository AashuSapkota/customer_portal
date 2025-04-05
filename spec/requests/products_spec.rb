require 'swagger_helper'

RSpec.describe 'Api::V1::Products', type: :request do
  path '/api/v1/products' do
    get 'List products' do
      tags 'Products'
      produces 'application/json'

      response '200', 'products found' do
        let!(:product) { create(:product) }
        run_test!
      end
    end
  end
end