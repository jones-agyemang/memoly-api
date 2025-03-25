Rails.application.routes.draw do
  resources :notes, only: %i[create]
end
