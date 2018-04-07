require "csv"

class StockPrice < ApplicationRecord
  belongs_to :stock

  def self.download_years(ticker_symbol, transaction_id)
    url = "https://kabuoji3.com/stock/#{ticker_symbol}/"
    object_key = "#{transaction_id}/stock_detail_#{ticker_symbol}.html"
    doc = Stock.download_and_parse_page(url, object_key)

    year_nodes = doc.xpath("//ul[@class='stock_yselect mt_10']/li/a")

    years = []
    year_nodes.each do |year_node|
      years << year_node.text.to_i if year_node.text.match(/^[0-9]{4}$/)
    end

    years.sort
  end

  def self.download_stock_prices(ticker_symbol, year, transaction_id)
    url = "https://kabuoji3.com/stock/file.php"
    object_key = "#{transaction_id}/stock_price_#{ticker_symbol}_#{year}.csv"
    form_data = { "code" => ticker_symbol, "year" => year }

    csv = Stock.post_data(url, form_data, object_key)

    stock_prices_data = []
    CSV.parse(csv) do |line|
      stock_prices_data << {
        date: Date.parse(line[0]),
        opening_price: line[1].to_i,
        high_price: line[2].to_i,
        low_price: line[3].to_i,
        close_price: line[4].to_i,
        turnover: line[5].to_i,
        adjustment_value: line[6].to_i
      } if line[0].match(/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/)
    end

    stock_prices_data
  end

  def self.import(ticker_symbol, data)
    stock = Stock.find_by(ticker_symbol: ticker_symbol)

    stock_price_ids = []

    data.each do |d|
      stock_prices = StockPrice.where("stock_id = :stock_id and date = :date", stock_id: stock.id, date: d[:date])
      if stock_prices.empty?
        stock_price = StockPrice.new(
          date: d[:date],
          opening_price: d[:opening_price],
          high_price: d[:high_price],
          low_price: d[:low_price],
          close_price: d[:close_price],
          turnover: d[:turnover],
          adjustment_value: d[:adjustment_value],
          stock: stock
        )
      else
        stock_price = stock_prices[0]
        stock_price.opening_price = d[:opening_price]
        stock_price.high_price = d[:high_price]
        stock_price.low_price = d[:low_price]
        stock_price.close_price = d[:close_price]
        stock_price.turnover = d[:turnover]
        stock_price.adjustment_value = d[:adjustment_value]
      end
      stock_price.save!

      stock_price_ids << stock_price.id
    end

    stock_price_ids
  end

end
