Rails.application.routes.draw do
  use_doorkeeper
  defaults format: :json do
    resources :users, only: %i[ index ]

    resources :users do
      get "due_notes", controller: "review_notes"
      resources :notes, only: %i[ create index update destroy ]
      resources :collections, only: %i[ index create update destroy ]
    end

    resource :user, only: [] do
      get "me", to: "users#me"
    end

    resources :quiz, controller: :quizzes, only: %i[create show]

    post "authentication/request-code"
    post "authentication/verify-code"

    get "discovery", to: "discovery#index", as: :discovery
  end
end
