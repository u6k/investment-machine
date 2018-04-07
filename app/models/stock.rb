require "nokogiri"
require "net/http"

class Stock < ApplicationRecord

  validates :ticker_symbol, presence: true, format: { with: /\d{4}/i }
  validates :company_name, presence: true, format: { with: /.+/i }
  validates :market, presence: true, format: { with: /.+/i }

  def self.download_index_page(transaction_id)
    url = "https://kabuoji3.com/stock/"
    object_key = "#{transaction_id}/index.html"

    self._download_with_get(url, object_key)

    object_key
  end

  def self.get_page_links(index_page_object_key)
    bucket = self._get_s3_bucket
    html = bucket.object(index_page_object_key).get.body

    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")

    pager_lines = doc.xpath("//ul[@class='pager']/li/a")

    page_links = []
    pager_lines.each do |pager_line|
      page_links << pager_line["href"]
    end

    page_links
  end

  def self.download_stock_list_page(transaction_id, page_link)
    url = "https://kabuoji3.com/stock/" + page_link
    object_key = "#{transaction_id}/stock_list_#{page_link}.html"

    self._download_with_get(url, object_key)

    object_key
  end

  def self.get_stocks(stock_list_page_object_key)
    bucket = self._get_s3_bucket
    html = bucket.object(stock_list_page_object_key).get.body

    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")

    stock_table_lines = doc.xpath("//table[@class='stock_table']/tbody/tr")

    stocks = []
    stock_table_lines.each do |stock_table_line|
      stock = Stock.new(
        ticker_symbol: stock_table_line.xpath("td/a").text[0..3],
        company_name: stock_table_line.xpath("td/a").text[5..-1],
        market: stock_table_line.xpath("td[2]").text
      )
      raise stock.errors.messages.to_s if stock.invalid?

      stocks << stock
    end

    stocks
  end

  def self.import(stocks)
    stock_ids = []

    stocks.each do |stock|
      s = Stock.find_by(ticker_symbol: stock.ticker_symbol)

      if s.nil?
        s = Stock.new(
          ticker_symbol: stock.ticker_symbol,
          company_name: stock.company_name,
          market: stock.market
        )
      else
        s.company_name = stock.company_name
        s.market = stock.market
      end

      s.save!
      stock_ids << s.id
    end

    stock_ids
  end

  def self.download_stock_detail_page(transaction_id, ticker_symbol)
    url = "https://kabuoji3.com/stock/#{ticker_symbol}/"
    object_key = "#{transaction_id}/stock_detail_#{ticker_symbol}.html"

    self._download_with_get(url, object_key)

    object_key
  end
 
  def self.get_years(stock_detail_page_object_key)
    bucket = self._get_s3_bucket
    html = bucket.object(stock_detail_page_object_key).get.body

    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")

    year_nodes = doc.xpath("//ul[@class='stock_yselect mt_10']/li/a")

    years = []
    year_nodes.each do |year_node|
      years << year_node.text.to_i if year_node.text.match(/^[0-9]{4}$/)
    end

    years.sort
  end

  def self._generate_transaction_id
    DateTime.now.strftime("%Y%m%d%H%M%S_#{SecureRandom.uuid}")
  end

  def self._validate_transaction_id(transaction_id)
    raise ArgumentError, "transaction_id invalid (#{transaction_id}" if not transaction_id.match(/^[0-9a-zA-Z\-_]+$/)
  end

  def self._get_s3_bucket
    Aws.config.update({
      region: Rails.application.secrets.s3_region,
      credentials: Aws::Credentials.new(Rails.application.secrets.s3_access_key, Rails.application.secrets.s3_secret_key)
    })
    s3 = Aws::S3::Resource.new(endpoint: Rails.application.secrets.s3_endpoint, force_path_style: true)

    bucket = s3.bucket(Rails.application.secrets.s3_bucket)
  end

  def self._download_with_get(url, object_key)
    uri = URI(url)

    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = "curl/7.54.0"
    req["Accept"] = "*/*"
 
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
      http.request(req)
    end

    bucket = Stock._get_s3_bucket
    object = bucket.object(object_key)
    object.put(body: res.body)
  end

  def self._download_with_post(url, data, object_key)
    uri = URI(url)

    req = Net::HTTP::Post.new(uri)
    req["User-Agent"] = "curl/7.54.0"
    req["Accept"] = "*/*"
    req.set_form_data(data)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
      http.request(req)
    end

    bucket = Stock._get_s3_bucket
    obj = bucket.object(object_key)
    obj.put(body: res.body)
  end

end
