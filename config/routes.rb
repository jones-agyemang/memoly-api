Rails.application.routes.draw do
  use_doorkeeper

  defaults format: :json do
    delete "session/logout"
    resources :users, only: %i[ index ]

    resources :users do
      get "due_notes", controller: "review_notes"
      resources :notes, only: %i[ create index update destroy ] do
        resources :images, controller: :image_attachments, only: %i[ create destroy ]
      end
      resources :collections, only: %i[ index create update destroy ] do
        resources :images, controller: :image_attachments, only: %i[ create destroy ]
      end
      resources :source_intake
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
