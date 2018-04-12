require "nokogiri"
require "net/http"

class Stock < ApplicationRecord

  validates :ticker_symbol, presence: true, format: { with: /\d{4}/i }
  validates :company_name, presence: true, format: { with: /.+/i }
  validates :market, presence: true, format: { with: /.+/i }

  def self.download_index_page(missing_only = false)
    url = "https://kabuoji3.com/stock/"
    file_name = "stock_list_index.html"

    keys = self._download_with_get(url, file_name, missing_only)
  end

  def self.get_page_links(object_key)
    bucket = self._get_s3_bucket
    html = bucket.object(object_key).get.body

    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")

    pager_lines = doc.xpath("//ul[@class='pager']/li/a")

    page_links = []
    pager_lines.each do |pager_line|
      page_links << pager_line["href"]
    end

    page_links
  end

  def self.download_stock_list_page(page_link, missing_only = false)
    url = "https://kabuoji3.com/stock/" + page_link
    file_name = "stock_list_#{page_link}.html"

    keys = self._download_with_get(url, file_name, missing_only)
  end

  def self.get_stocks(object_key)
    bucket = self._get_s3_bucket
    html = bucket.object(object_key).get.body

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

    Stock.transaction do
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
    end

    stock_ids
  end

  def self.download_stock_detail_page(ticker_symbol, missing_only = false)
    url = "https://kabuoji3.com/stock/#{ticker_symbol}/"
    file_name = "stock_detail_#{ticker_symbol}.html"

    keys = self._download_with_get(url, file_name, missing_only)
  end
 
  def self.get_years(object_key)
    bucket = self._get_s3_bucket
    html = bucket.object(object_key).get.body

    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")

    year_nodes = doc.xpath("//ul[@class='stock_yselect mt_10']/li/a")

    years = []
    year_nodes.each do |year_node|
      years << year_node.text.to_i if year_node.text.match(/^[0-9]{4}$/)
    end

    years.sort
  end

  def self._get_s3_bucket
    Aws.config.update({
      region: Rails.application.secrets.s3_region,
      credentials: Aws::Credentials.new(Rails.application.secrets.s3_access_key, Rails.application.secrets.s3_secret_key)
    })
    s3 = Aws::S3::Resource.new(endpoint: Rails.application.secrets.s3_endpoint, force_path_style: true)

    bucket = s3.bucket(Rails.application.secrets.s3_bucket)
  end

  def self._get_s3_objects_size(objects)
    count = 0
    objects.each { |obj| count += 1 }

    count
  end

  def self._download_with_get(url, file_name, missing_only)
    bucket = Stock._get_s3_bucket

    obj_original = bucket.object(file_name)
    if obj_original.exists? && missing_only
      keys = { original: obj_original.key }
    else
      uri = URI(url)

      req = Net::HTTP::Get.new(uri)
      req["User-Agent"] = "curl/7.54.0"
      req["Accept"] = "*/*"

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
        http.request(req)
      end

      sleep(1)

      obj_original = bucket.object(file_name)
      obj_original.put(body: res.body)
      obj_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d%H%M%S"))
      obj_backup.put(body: res.body)

      keys = {original: obj_original.key, backup: obj_backup.key}
    end
  end

  def self._download_with_post(url, data, file_name, missing_only)
    bucket = Stock._get_s3_bucket

    obj_original = bucket.object(file_name)
    if obj_original.exists? && missing_only
      keys = { original: obj_original.key }
    else
      uri = URI(url)

      req = Net::HTTP::Post.new(uri)
      req["User-Agent"] = "curl/7.54.0"
      req["Accept"] = "*/*"
      req.set_form_data(data)

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
        http.request(req)
      end

      sleep(1)

      obj_original = bucket.object(file_name)
      obj_original.put(body: res.body)
      obj_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d%H%M%S"))
      obj_backup.put(body: res.body)

      keys = {original: obj_original.key, backup: obj_backup.key}
    end
  end

end
