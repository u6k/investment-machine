require "nokogiri"
require "net/http"

class Stock < ApplicationRecord

  validates :ticker_symbol, presence: true, format: { with: /\d{4}/i }
  validates :company_name, presence: true, format: { with: /.+/i }
  validates :market, presence: true, format: { with: /.+/i }

  def self.download_index_page
    url = "https://kabuoji3.com/stock/"

    index_page_data = self._download_with_get(url)
    page_links = get_page_links(index_page_data)

    { data: index_page_data, page_links: page_links }
  end

  def self.put_index_page(bucket, index_page_data)
    file_name = "stock_list_index.html"

    object_original = bucket.object(file_name)
    object_original.put(body: index_page_data)

    object_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d-%H%M%S"))
    object_backup.put(body: index_page_data)

    { original: object_original.key, backup: object_backup.key }
  end

  def self.get_page_links(index_page_data)
    doc = Nokogiri::HTML.parse(index_page_data, nil, "UTF-8")

    pager_lines = doc.xpath("//ul[@class='pager']/li/a")

    page_links = []
    pager_lines.each do |pager_line|
      page_links << pager_line["href"]
    end

    page_links
  end

  def self.download_stock_list_page(page_link)
    url = "https://kabuoji3.com/stock/" + page_link

    stock_list_page_data = self._download_with_get(url)
    stocks = get_stocks(stock_list_page_data)

    { data: stock_list_page_data, stocks: stocks }
  end

  def self.put_stock_list_page(bucket, page_link, stock_list_page_data)
    file_name = "stock_list_#{page_link}.html"

    object_original = bucket.object(file_name)
    object_original.put(body: stock_list_page_data)

    object_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d-%H%M%S"))
    object_backup.put(body: stock_list_page_data)

    { original: object_original.key, backup: object_backup.key }
  end

  def self.get_stocks(stock_list_page_data)
    doc = Nokogiri::HTML.parse(stock_list_page_data, nil, "UTF-8")

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

    object = Stock._get_s3_bucket.object(file_name)
    if object.exists? && missing_only
      []
    else
      stock_detail_page_data = _download_with_get(url)

      get_years(stock_detail_page_data)
    end
  end
 
  def self.get_years(stock_detail_page_data)
    doc = Nokogiri::HTML.parse(stock_detail_page_data, nil, "UTF-8")

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

  def self._put_s3_object(bucket, file_name, data)
    obj_original = bucket.object(file_name)
    obj_original.put(body: data)

    obj_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d%H%M%S"))
    obj_backup.put(body: data)
  end

  def self._download_with_get(url)
    uri = URI(url)

    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = "curl/7.54.0"
    req["Accept"] = "*/*"

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
      http.request(req)
    end

    sleep(1)

    res.body
  end

  def self._download_with_post(url, data)
    uri = URI(url)

    req = Net::HTTP::Post.new(uri)
    req["User-Agent"] = "curl/7.54.0"
    req["Accept"] = "*/*"
    req.set_form_data(data)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
      http.request(req)
    end

    sleep(1)

    res.body
  end

end
