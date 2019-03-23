#require "nokogiri"
#require "net/http"
#
#class Stock < ApplicationRecord
#
#  validates :ticker_symbol, presence: true, format: { with: /\d{4}/i }
#  validates :company_name, presence: true, format: { with: /.+/i }
#  validates :market, presence: true, format: { with: /.+/i }
#
#  def self.build_index_page_file_name
#    "stock_list_index.html"
#  end
#
#  def self.download_index_page
#    url = "https://kabuoji3.com/stock/"
#
#    data = Stock._download_with_get(url)
#    page_links = parse_index_page(data)
#
#    { data: data, page_links: page_links }
#  end
#
#  def self.put_index_page(data)
#    file_name = build_index_page_file_name
#
#    bucket = Stock._get_s3_bucket
#    Stock._put_s3_object(bucket, file_name, data)
#  end
#
#  def self.get_index_page
#    file_name = build_index_page_file_name
#
#    bucket = Stock._get_s3_bucket
#    Stock._get_s3_object(bucket, file_name)
#  end
#
#  def self.parse_index_page(html)
#    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")
#
#    pager_lines = doc.xpath("//ul[@class='pager']/li/a")
#
#    page_links = []
#    pager_lines.each do |pager_line|
#      page_links << pager_line["href"]
#    end
#
#    page_links
#  end
#
#  def self.build_stock_list_page_file_name(page_link)
#    "stock_list_#{page_link}.html"
#  end
#
#  def self.download_stock_list_page(page_link)
#    url = "https://kabuoji3.com/stock/" + page_link
#
#    data = self._download_with_get(url)
#    stocks = parse_stock_list_page(data)
#
#    { data: data, stocks: stocks }
#  end
#
#  def self.put_stock_list_page(page_link, data)
#    file_name = build_stock_list_page_file_name(page_link)
#
#    bucket = Stock._get_s3_bucket
#    Stock._put_s3_object(bucket, file_name, data)
#  end
#
#  def self.get_stock_list_page(page_link)
#    file_name = build_stock_list_page_file_name(page_link)
#
#    bucket = Stock._get_s3_bucket
#    Stock._get_s3_object(bucket, file_name)
#  end
#
#  def self.parse_stock_list_page(html)
#    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")
#
#    stock_table_lines = doc.xpath("//table[@class='stock_table']/tbody/tr")
#
#    stocks = []
#    stock_table_lines.each do |stock_table_line|
#      stock = Stock.new(
#        ticker_symbol: stock_table_line.xpath("td/a").text[0..3],
#        company_name: stock_table_line.xpath("td/a").text[5..-1],
#        market: stock_table_line.xpath("td[2]").text
#      )
#      raise stock.errors.messages.to_s if stock.invalid?
#
#      stocks << stock
#    end
#
#    stocks
#  end
#
#  def self.import(stocks)
#    stock_ids = []
#
#    Stock.transaction do
#      stocks.each do |stock|
#        s = Stock.find_by(ticker_symbol: stock.ticker_symbol)
#
#        if s.nil?
#          s = Stock.new(
#            ticker_symbol: stock.ticker_symbol,
#            company_name: stock.company_name,
#            market: stock.market
#          )
#        else
#          s.company_name = stock.company_name
#          s.market = stock.market
#        end
#
#        s.save!
#        stock_ids << s.id
#      end
#    end
#
#    stock_ids
#  end
#
#  def self.build_stock_detail_page_file_name(ticker_symbol)
#    "stock_detail_#{ticker_symbol}.html"
#  end
#
#  def self.download_stock_detail_page(ticker_symbol, missing_only = false)
#    url = "https://kabuoji3.com/stock/#{ticker_symbol}/"
#    file_name = build_stock_detail_page_file_name(ticker_symbol)
#
#    object = Stock._get_s3_bucket.object(file_name)
#    if object.exists? && missing_only
#      nil
#    else
#      data = _download_with_get(url)
#      years = parse_stock_detail_page(data)
#
#      { data: data, years: years }
#    end
#  end
#
#  def self.put_stock_detail_page(ticker_symbol, data)
#    file_name = build_stock_detail_page_file_name(ticker_symbol)
#
#    bucket = Stock._get_s3_bucket
#    Stock._put_s3_object(bucket, file_name, data)
#  end
#
#  def self.get_stock_detail_page(ticker_symbol)
#    file_name = build_stock_detail_page_file_name(ticker_symbol)
#
#    bucket = Stock._get_s3_bucket
#    Stock._get_s3_object(bucket, file_name)
#  end
# 
#  def self.parse_stock_detail_page(data)
#    doc = Nokogiri::HTML.parse(data, nil, "UTF-8")
#
#    year_nodes = doc.xpath("//ul[@class='stock_yselect mt_10']/li/a")
#
#    years = []
#    year_nodes.each do |year_node|
#      years << year_node.text.to_i if year_node.text.match(/^[0-9]{4}$/)
#    end
#
#    years.sort
#  end
#
#  def self._get_s3_bucket
#    Aws.config.update({
#      region: Rails.application.secrets.s3_region,
#      credentials: Aws::Credentials.new(Rails.application.secrets.s3_access_key, Rails.application.secrets.s3_secret_key)
#    })
#    s3 = Aws::S3::Resource.new(endpoint: Rails.application.secrets.s3_endpoint, force_path_style: true)
#
#    bucket = s3.bucket(Rails.application.secrets.s3_bucket)
#  end
#
#  def self._get_s3_objects_size(objects)
#    count = 0
#    objects.each { |obj| count += 1 }
#
#    count
#  end
#
#  def self._put_s3_object(bucket, file_name, data)
#    obj_original = bucket.object(file_name)
#    obj_original.put(body: data)
#
#    obj_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d-%H%M%S"))
#    obj_backup.put(body: data)
#
#    { original: obj_original.key, backup: obj_backup.key }
#  end
#
#  def self._get_s3_object(bucket, file_name)
#    object = bucket.object(file_name)
#    data = object.get.body.read(object.size)
#  end
#
#  def self._download_with_get(url)
#    uri = URI(url)
#
#    req = Net::HTTP::Get.new(uri)
#    req["User-Agent"] = "curl/7.54.0"
#    req["Accept"] = "*/*"
#
#    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https", :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
#      http.request(req)
#    end
#
#    sleep(1)
#
#    res.body
#  end
#
#  def self._download_with_post(url, data)
#    uri = URI(url)
#
#    req = Net::HTTP::Post.new(uri)
#    req["User-Agent"] = "curl/7.54.0"
#    req["Accept"] = "*/*"
#    req.set_form_data(data)
#
#    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == "https") do |http|
#      http.request(req)
#    end
#
#    sleep(1)
#
#    res.body
#  end
#
#end
