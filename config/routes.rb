Rails.application.routes.draw do

  root 'application#home'
  get 'identity' => "application#identity"

  resources :assignments, only: [:create, :update]
  resources :contracts, only: [:create]
  resources :snapshots, only: [:create, :update]
  post 'api/block_cypher/confirmations/:auth_key' => 'block_cypher#tx_confirmation'

end
