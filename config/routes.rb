Rails.application.routes.draw do
  devise_for :users, controllers: {
    # ↓ローカルに追加されたコントローラーを参照する(コントローラー名: "コントローラーの参照先")
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  # sidekiqの処理
  require 'sidekiq/web'
  mount Sidekiq::Web => "/sidekiq"

  root to: "tops#index"
  resources :companies do
    collection do
      get 'search'
    end
  end
  resources :imitsus do
    collection do
      get 'search'
    end
  end
  resources :rekaizens do
    collection do
      get 'search'
    end
  end
  resources :baseconnects do
    collection do
      get 'search'
    end
  end
  resources :aimitsus do
    collection do
      get 'search'
    end
  end
  resources :keywords do
    collection do
      get 'search'
    end
  end
end
