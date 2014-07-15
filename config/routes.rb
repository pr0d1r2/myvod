Myvod::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root to: 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  resources :videos, only: [:show, :update, :index]
  resources :orginals, only: [:show]
  resources :likes, only: [:index]
  resources :bests, only: [:index]
  resources :unseens, only: [:index, :show]
  resources :random_bests, only: [:show]
  resources :random_likes, only: [:show]

  resources :magnets, only: [:show, :update, :index]

  get 'v' => 'videos#index'
  get 'l' => 'likes#index'
  get 'b' => 'bests#index'
  get 'u' => 'unseens#index'
  get 'n' => 'unseens#show', :id => 1
  get 'rb' => 'random_bests#show', :id => 1
  get 'rl' => 'random_likes#show', :id => 1

  get 'm' => 'magnets#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  require 'sidetiq/web'

  root to: 'welcome#index'
end
