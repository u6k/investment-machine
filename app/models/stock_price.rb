require "csv"

class StockPrice < ApplicationRecord
  belongs_to :stock

  validates :date, presence: true
  validates :opening_price, presence: true
  validates :high_price, presence: true
  validates :low_price, presence: true
  validates :close_price, presence: true
  validates :turnover, presence: true
  validates :adjustment_value, presence: true

  def self.download_stock_price_csv(ticker_symbol, year)
    url = "https://kabuoji3.com/stock/file.php"
    file_name = "stock_price_#{ticker_symbol}_#{year}.csv"
    form_data = { "code" => ticker_symbol, "year" => year }

    keys = Stock._download_with_post(url, form_data, file_name)
  end

  def self.get_stock_prices(object_key, ticker_symbol)
    stock = Stock.find_by(ticker_symbol: ticker_symbol)

    bucket = Stock._get_s3_bucket
    csv = bucket.object(object_key).get.body

    csv = csv.string.encode("UTF-8", "Shift_JIS")

    stock_prices = []
    CSV.parse(csv) do |line|
      if line[0].match(/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/)
        stock_price = StockPrice.new(
          date: Date.parse(line[0]),
          opening_price: line[1].to_i,
          high_price: line[2].to_i,
          low_price: line[3].to_i,
          close_price: line[4].to_i,
          turnover: line[5].to_i,
          adjustment_value: line[6].to_i,
          stock: stock
        )
        raise stock_price.errors.messages.to_s if stock_price.invalid?

        stock_prices << stock_price
      end
    end

    stock_prices
  end

  def self.import(stock_prices)
    stock_price_ids = []

    StockPrice.transaction do
      stock_prices.each do |stock_price|
        ps = StockPrice.where("stock_id = :stock_id and date = :date", stock_id: stock_price.stock.id, date: stock_price.date)
        if ps.empty?
          p = StockPrice.new(
            date: stock_price.date,
            opening_price: stock_price.opening_price,
            high_price: stock_price.high_price,
            low_price: stock_price.low_price,
            close_price: stock_price.close_price,
            turnover: stock_price.turnover,
            adjustment_value: stock_price.adjustment_value,
            stock: stock_price.stock
          )
        else
          p = ps[0]
          p.opening_price = stock_price.opening_price
          p.high_price = stock_price.high_price
          p.low_price = stock_price.low_price
          p.close_price = stock_price.close_price
          p.turnover = stock_price.turnover
          p.adjustment_value = stock_price.adjustment_value
        end

        p.save!
        stock_price_ids << p.id
      end
    end

    stock_price_ids
  end

end
