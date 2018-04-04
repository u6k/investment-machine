require "open-uri"
require "nokogiri"

namespace :crawl do
  desc "Crawler"

  task stocks: :environment do
    url = "https://kabuoji3.com/stock/"
    http_header = {
      "User-Agent" => "curl/7.54.0",
      "Accept" => "*/*"
    }

    sleep(1)

    charset = nil
    html = open(url, http_header) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    p doc.title

    stock_table_lines = doc.xpath("//table[@class='stock_table']/tbody/tr/td/a")

    stocks = []
    stock_table_lines.each do |stock_table_line|
      stocks << {
        "code" => stock_table_line.text[0..3],
        "name" => stock_table_line.text[5..-1]
      }
    end

    pager_lines = doc.xpath("//ul[@class='pager']/li/a")

    page_links = []
    pager_lines.each do |pager_line|
      page_links << pager_line["href"]
    end

    p stocks
    p page_links
  end

end
