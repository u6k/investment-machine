require "open-uri"
require "nokogiri"
require "aws-sdk-s3"

namespace :crawl do
  desc "Crawler"

  # TODO
  task :hello, [:ticker_symbol, :year] => :environment do |task, args|
    p "hello"
    p task
    p args
  end

  task stocks: :environment do
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    Rails.logger.info "stocks: start"

    transaction_id = Stock._generate_transaction_id
    Rails.logger.info "transaction_id=#{transaction_id}"

    Rails.logger.info "download_index_page and get_page_links: start"
    sleep(1)
    index_page_object_key = Stock.download_index_page(transaction_id)
    page_links = Stock.get_page_links(index_page_object_key)
    Rails.logger.info "download_index_page and get_page_links: end: page_links.length=#{page_links.length}"

    page_links.each do |page_link|
      Rails.logger.info "download_stock_list_page and import: start: page_link=#{page_link}"
      sleep(1)
      stock_list_page_object_key = Stock.download_stock_list_page(transaction_id, page_link)
      stocks = Stock.get_stocks(stock_list_page_object_key)
      Stock.import(stocks)
      Rails.logger.info "download_stock_list_page and import: end: stocks.length=#{stocks.length}"
    end

    Rails.logger.info "stocks: end: Stock.all.length=#{Stock.all.length}"
  end

end
