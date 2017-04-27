Rails.application.routes.draw do

  root 'application#home'
  get 'identity' => "application#identity"

  resources :assignments, only: [:create, :show, :update] do
    resources :snapshots, only: [:create]
  end
  resources :contracts, only: [:create]
  resources :json_receivers, only: [] do
    resources :requests, only: [:create], controller: 'json_receiver/requests'
  end
  resources :snapshots, only: [:create, :update]
  resources :subtasks, only: [] do
    resources :snapshots, only: [:create], controller: 'subtask/snapshots'
  end
  post 'api/block_cypher/confirmations/:auth_key' => 'block_cypher#tx_confirmation'

  scope path: '/wei_watchers' do
    post '/events' => 'wei_watchers/events#create'
  end

end
