Rails.application.routes.draw do
  resources :collections
  defaults format: :json do
    resources :users, only: %i[ index ]

    resources :users do
      resources :notes, only: %i[ create index update destroy ]
    end

    resources :quiz, controller: :quizzes, only: %i[create show]

    post "authentication/request-code"
    post "authentication/verify-code"
  end
end
