Rails.application.routes.draw do

  root "application#hello"

  namespace :api do
    resources :stocks
  end

end
