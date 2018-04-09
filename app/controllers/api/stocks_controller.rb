class Api::StocksController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    @stocks = Stock.all

    render json: @stocks, except: [:id, :created_at, :updated_at]
  end

  def show
    @stock = Stock.find_by(ticker_symbol: params[:id])

    render json: @stock, except: [:id, :created_at, :updated_at]
  end

end
