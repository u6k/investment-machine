class Api::StocksController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    @stocks = Stock.all

    render json: @stocks, except: [:id, :created_at, :updated_at]
  end

end
