require "open-uri"
require "nokogiri"
require "aws-sdk-s3"

namespace :crawl do
  desc "Crawler"

  task stocks: :environment do
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    Rails.logger.info "stocks: start"

    transaction_id = Stock._generate_transaction_id
    Rails.logger.info "transaction_id=#{transaction_id}"

    Rails.logger.info "download_index_page and get_page_links: start"
    index_page_object_key = Stock.download_index_page(transaction_id)
    page_links = Stock.get_page_links(index_page_object_key)
    Rails.logger.info "download_index_page and get_page_links: end: page_links.length=#{page_links.length}"

    page_links.each do |page_link|
      Rails.logger.info "download_stock_list_page and import: start: page_link=#{page_link}"
      stock_list_page_object_key = Stock.download_stock_list_page(transaction_id, page_link)
      stocks = Stock.get_stocks(stock_list_page_object_key)
      Stock.import(stocks)
      Rails.logger.info "download_stock_list_page and import: end: stocks.length=#{stocks.length}"
    end

    Rails.logger.info "stocks: end: Stock.all.length=#{Stock.all.length}"
  end

  task :stock_prices, [:ticker_symbol, :year] => :environment do |task, args|
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    Rails.logger.info "stock_prices: start: ticker_symbol=#{args.ticker_symbol}, year=#{args.year}"

    transaction_id = Stock._generate_transaction_id
    Rails.logger.info "transaction_id=#{transaction_id}"

    if args.ticker_symbol == "all"
      stocks = Stock.all
    else
      stocks = Stock.where("ticker_symbol = :ticker_symbol", ticker_symbol: args.ticker_symbol)
    end
    Rails.logger.info "target stocks.length=#{stocks.length}"

    stocks.each.with_index(1) do |stock, stock_index|
      Rails.logger.info "foreach stock: start: #{stock_index}/#{stocks.length} ticker_symbol=#{stock.ticker_symbol}"

      if args.year == "all"
        stock_detail_page_object_key = Stock.download_stock_detail_page(transaction_id, stock.ticker_symbol)
        years = Stock.get_years(stock_detail_page_object_key)
      else
        years = [args.year.to_i]
      end
      Rails.logger.info "target years=#{years}"

      years.each do |year|
        Rails.logger.info "download_stock_price_csv: start: year=#{year}"
        stock_price_csv_object_key = StockPrice.download_stock_price_csv(transaction_id, stock.ticker_symbol, year)
        Rails.logger.info "download_stock_price_csv: end"

        Rails.logger.info "get and import stock_prices: start"
        stock_prices = StockPrice.get_stock_prices(stock.ticker_symbol, stock_price_csv_object_key)
        StockPrice.import(stock_prices)
        Rails.logger.info "get and import stock_prices: end: length=#{stock_prices.length}"
      end

      Rails.logger.info "foreach stock: end"
    end
  end

end
