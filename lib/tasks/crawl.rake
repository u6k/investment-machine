require "open-uri"
require "nokogiri"
require "aws-sdk-s3"

namespace :crawl do
  desc "Crawler"

  task hello: :environment do
    Aws.config.update({
      region: "my_region",
      credentials: Aws::Credentials.new("s3_access_key", "s3_secret_key")
    })
    s3 = Aws::S3::Resource.new(endpoint: "http://s3:9000", force_path_style: true)

    bucket = s3.bucket("hello")
    obj = bucket.object("hello.txt")
    obj.put(body: "test")
  end

  task stocks: :environment do
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO
    Rails.logger.info "stocks: start"

    Rails.logger.info "  download_page_links: start"
    page_links = Stock.download_page_links
    sleep(1)
    Rails.logger.info "  download_page_links: end: length=#{page_links.length}"

    page_links.each do |page_link|
      Rails.logger.info "  download_stocks: start: #{page_link}"
      stocks_data = Stock.download_stocks(page_link)
      sleep(1)
      Rails.logger.info "  download_stocks: end: length=#{stocks_data.length}"

      Rails.logger.info "  import: start"
      stocks = Stock.import(stocks_data)
      Rails.logger.info "  import: end: length=#{stocks.length}"
    end

    Rails.logger.info "stocks: end: Stock.all.length=#{Stock.all.length}"
  end

end
