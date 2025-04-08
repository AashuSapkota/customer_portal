# config/routes.rb
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      post 'login', to: 'authentication#login'
      post 'signup', to: 'authentication#signup'
      
      resources :delivery_orders do
        post 'documents', to: 'delivery_orders#add_document'
        post 'chats', to: 'delivery_orders#add_chat_message'
        get 'export', on: :collection, format: 'xlsx'
      end
      
      resources :vendors do
        post 'set_preferred', on: :member
      end
      
      resources :contracts do
        post 'sign', on: :member
      end
      
      resources :branches
      resources :products, only: [:index]
      
      resources :feature_flags do
        collection do
          get ':flaggable_type/:flaggable_id', to: 'feature_flags#index'
          post ':flaggable_type/:flaggable_id', to: 'feature_flags#create'
        end
        
        member do
          get ':flaggable_type/:flaggable_id', to: 'feature_flags#show'
          patch ':flaggable_type/:flaggable_id', to: 'feature_flags#update'
          delete ':flaggable_type/:flaggable_id', to: 'feature_flags#destroy'
        end
      end
      
      resources :third_party_integrations do
        post 'sync', on: :member
      end
    end
  end

  # UI Routes

  get 'login', to: 'auth#new_session', as: :login
  post 'login', to: 'auth#create_session'
  get 'signup', to: 'auth#new_registration', as: :signup
  post 'signup', to: 'auth#create_registration'
  delete 'logout', to: 'auth#destroy_session', as: :logout

  
  resources :vendors, only: [:index, :show, :new, :edit]
  
  # For health checks
  get 'health', to: 'health#check'
end