require "open-uri"
require "nokogiri"

class Stock < ApplicationRecord

  def self.download_page_links
    url = "https://kabuoji3.com/stock/"
    http_header = {
      "User-Agent" => "curl/7.54.0",
      "Accept" => "*/*"
    }

    charset = nil
    html = open(url, http_header) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)

    pager_lines = doc.xpath("//ul[@class='pager']/li/a")

    page_links = []
    pager_lines.each do |pager_line|
      page_links << pager_line["href"]
    end

    page_links
  end

  def self.download_stocks(page_link)
    url = "https://kabuoji3.com/stock/"
    http_header = {
      "User-Agent" => "curl/7.54.0",
      "Accept" => "*/*"
    }

    charset = nil
    html = open(url, http_header) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)

    stock_table_lines = doc.xpath("//table[@class='stock_table']/tbody/tr/td/a")

    stocks = []
    stock_table_lines.each do |stock_table_line|
      stocks << {
        code: stock_table_line.text[0..3],
        name: stock_table_line.text[5..-1]
      }
    end

    stocks
  end


end
