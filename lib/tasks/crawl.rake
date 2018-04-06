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

    Rails.logger.info "download_page_links: start"
    page_links = Stock.download_page_links(transaction_id)
    sleep(1)
    Rails.logger.info "download_page_links: end: length=#{page_links.length}"

    page_links.each do |page_link|
      Rails.logger.info "download_stocks: start: #{page_link}"
      stocks_data = Stock.download_stocks(page_link, transaction_id)
      sleep(1)
      Rails.logger.info "import: start"
      stocks = Stock.import(stocks_data)
      Rails.logger.info "import: end: length=#{stocks.length}"
    end

    Rails.logger.info "stocks: end: Stock.all.length=#{Stock.all.length}"
  end

end
