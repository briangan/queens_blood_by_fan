Rails.application.routes.draw do
  resources :decks, only:[:index, :show, :update] do
    member do
      match 'select_deck_cards', to: 'decks#select_deck_cards', via:[:get, :post, :put, :patch]
    end
  end

  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :users
  resources :cards
  resources :card_abilities
  resources :games, only:[:index, :new, :create, :show] do
    member do
      match 'join', to: 'games#join', via:[:get, :post, :put, :patch]
      match 'create_game_move', to: 'games#create_game_move', via:[:get, :post, :put, :patch]
      match 'reset', to: 'games#reset', via:[:get, :post, :put, :patch]
    end
  end
  resources :boards

  # Streaming #################
  
  mount ActionCable.server => '/cable'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  match 'access_denied', to: 'home#access_denied', via: [:get, :post]
  root 'home#index'
end
