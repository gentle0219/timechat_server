TimeChatNet::Application.routes.draw do	
  namespace :admin do
    get '', to: 'dashboard#index', as: '/'

    resources :users
  end
  
  mount API => '/'

  devise_for :users, controllers: {sessions: "sessions"}
  root :to => 'home#index'
  
  post 'api/v1/accounts/sign_up'        => 'home#sign_up'
  post 'api/v1/accounts/sign_in'        => 'home#create_session'
  post 'api/v1/accounts/sign_out'       => 'home#delete_session'

  get 'users/destroy/:id'               => 'home#destroy', as: :destroy_user
  
end
