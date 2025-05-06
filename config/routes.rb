Rails.application.routes.draw do
  defaults format: :json do
    resources :notes, only: %i[create index]
    resources :quiz, controller: :quizzes, only: %i[create show]

    post "authentication/request-code"
    post "authentication/verify-code"
  end
end
