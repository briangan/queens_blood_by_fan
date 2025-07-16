Rails.application.routes.draw do
  resources :decks
  devise_for :users
  resources :users
  resources :cards
  resources :card_abilities
  resources :games, only:[:create, :show] do
    member do
      match 'create_game_move', to: 'games#create_game_move', via:[:get, :post, :put, :patch]
    end
  end
  resources :boards
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
end
