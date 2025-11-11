Rails.application.routes.draw do
  defaults format: :json do
    resources :users, only: %i[ index ]

    resources :users do
      resources :notes, only: %i[ create index update destroy ]
      resources :collections, only: %i[ index create update destroy ]
    end

    resources :quiz, controller: :quizzes, only: %i[create show]

    post "authentication/request-code"
    post "authentication/verify-code"
  end
end
