Rails.application.routes.draw do
  resources :sessions, :only => [:new, :create, :destroy]
  resources :microposts, :only => [:create, :destroy]
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :relationships, :only => [:create, :destroy]
  scope "(:locale)", :locale => /en|fr/ do
    root :to => 'pages#home'
    get '/contact', :to => 'pages#contact'
    get '/about',   :to => 'pages#about'
    get '/help',    :to => 'pages#help'
    get '/signup',  :to => 'users#new'
    get '/signin',  :to => 'sessions#new'
    get '/signout',  :to => 'sessions#destroy'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
