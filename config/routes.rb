Rails.application.routes.draw do

  root "application#hello"

  namespace :api do
    resources :stocks

    resources :stocks do
      resources :stock_prices
    end
  end

end
