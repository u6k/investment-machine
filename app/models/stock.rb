require "open-uri"
require "nokogiri"

class Stock < ApplicationRecord

  def self.download_page_links(transaction_id)
    url = "https://kabuoji3.com/stock/"
    object_key = "#{transaction_id}/index.html"
    doc = self.download_and_parse_page(url, object_key)

    pager_lines = doc.xpath("//ul[@class='pager']/li/a")

    page_links = []
    pager_lines.each do |pager_line|
      page_links << pager_line["href"]
    end

    page_links
  end

  def self.download_stocks(page_link, transaction_id)
    url = "https://kabuoji3.com/stock/" + page_link
    object_key = "#{transaction_id}/stock_list_#{page_link}.html"
    doc = self.download_and_parse_page(url, object_key)

    stock_table_lines = doc.xpath("//table[@class='stock_table']/tbody/tr/td/a")

    stocks = []
    stock_table_lines.each do |stock_table_line|
      stocks << {
        ticker_symbol: stock_table_line.text[0..3],
        company_name:  stock_table_line.text[5..-1]
      }
    end

    stocks
  end

  def self.import(data)
    stocks = []

    data.each do |d|
      stock = Stock.find_by(ticker_symbol: d[:ticker_symbol])
      if stock == nil
        stock = Stock.new(
          ticker_symbol: d[:ticker_symbol],
          company_name: d[:company_name]
        )
      else
        stock.company_name = d[:company_name]
      end
      stock.save!

      stocks << stock
    end

    stocks
  end

  def self._generate_transaction_id
    DateTime.now.strftime("%Y%m%d%H%M%S_#{SecureRandom.uuid}")
  end

  def self._get_s3_bucket
    # TODO
    Aws.config.update({
      region: "my_region",
      credentials: Aws::Credentials.new("s3_access_key", "s3_secret_key")
    })
    s3 = Aws::S3::Resource.new(endpoint: "http://s3:9000", force_path_style: true)

    bucket = s3.bucket("hello")
  end

  private

  def self.download_and_parse_page(url, object_key)
    http_header = {
      "User-Agent" => "curl/7.54.0",
      "Accept" => "*/*"
    }

    charset = nil
    html = open(url, http_header) do |f|
      charset = f.charset
      f.read
    end

    bucket = Stock._get_s3_bucket
    object = bucket.object(object_key)
    object.put(body: html)

    doc = Nokogiri::HTML.parse(html, nil, charset)
  end

  def validate_transaction_id(transaction_id)
    raise ArgumentError, "transaction_id invalid (#{transaction_id}" if not transaction_id.match(/^[0-9a-zA-Z\-_]+$/)
  end

end
