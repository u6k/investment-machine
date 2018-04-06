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

end
