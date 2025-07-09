Rails.application.routes.draw do
  resources :users
  resources :cards
  resources :card_abilities
  resources :games
  resources :boards
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
end
