Spree::Core::Engine.add_routes do
  get '/product_recently_viewed' => 'products#recently_viewed'
  resources :recently_viewed_products, only: [:index]
  get 'recently_viewed_products/clear_all', to: 'recently_viewed_products#clear_all', as: :clear_recently_viewed_products
end
