Rails.application.routes.draw do
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"

  resources :sessions, only: [:new, :create, :destroy]
  resources :product_types, only: :index
  resources :projects, only: [:index, :show, :create, :update] do
    member do
      get :export
      patch :mark_as_sold
      patch :update_view_options
    end

    resources :documents, only: [:create, :destroy] do
      post :unarchive, on: :member
    end
  end
  resources :documents, only: [] do
    post :create_renewal_proposal, on: :member
  end

  resources :dynamic_values, only: :update do
    put :bulk_update, on: :collection
  end

  namespace :admin do
    resource :copy, only: :create

    shallow do
      resources :projects, only: :show do
        resources :documents, only: [:show, :update, :create] do
          member do
            get :data_entry_finished
            get :review_finished
          end

          resources :sources, only: [:create, :show, :update]
          resources :products, only: [:update, :create, :destroy] do
            resources :product_classes, only: [:update, :create, :destroy]
          end
        end
      end
    end

    resources :dynamic_attributes
    resources :contextual_contents, only: [:new, :create, :edit, :update, :destroy]
    resources :product_types
    resources :categories
    resources :carriers do
      resources :orderings
    end
    resources :users, only: [] do
      get :stop_impersonation, on: :collection
      get :impersonate, on: :member
    end
    get "/" => "pages#dashboard"
  end

  api_version module: 'Api::V1', path: {value: '/api/v1'} do
    resources :carriers, only: [:index, :show] do  #not_used: show
      get :attribute_order, on: :member
    end
    resources :employers, only: [:index, :show] #not_used: index show
    resources :product_types, only: [:index, :show] #not_used: show
    resources :sources, only: [:show, :update] #not_used: show

    resources :projects, only: [:index, :show] do #not_used: index show
      get 'in-force', on: :member

      resources :documents, only: [:index] do #not_used: index
      end
    end
    resources :documents, only: [:show, :update] do
      get :types, on: :collection
      resources :products, only: [:index, :create] #not_used: index
    end
    resources :products, only: [:show, :destroy] do #not_used: show
      post :match_current, on: :member
      resources :product_classes, only: [:index, :create] #not_used: index
    end
    resources :product_classes, only: [:show, :destroy] do  #not_used: show
      post :clone_class, on: :member
      post :match_current, on: :member
    end
    resources :dynamic_values, only: [:show, :update] do #not_used: show
      post :clone_request, on: :member
      post :match_current, on: :member
    end
  end

  root 'pages#index'
end
