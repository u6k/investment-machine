class Api::StockPricesController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    stock = Stock.find_by(ticker_symbol: params[:stock_id])
    @stock_prices = StockPrice.where("stock_id = :stock_id", stock_id: stock.id)

    render json: @stock_prices, except: [:id, :stock_id, :created_at, :updated_at]
  end

end
