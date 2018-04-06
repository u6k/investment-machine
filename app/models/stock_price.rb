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

end
