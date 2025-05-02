Rails.application.routes.draw do
  defaults format: :json do
    resources :notes, only: %i[create index]

    post "authentication/request-code"
  end
end
