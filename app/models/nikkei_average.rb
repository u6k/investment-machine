class NikkeiAverage < ApplicationRecord
  validates :date, presence: true
  validates :opening_price, presence: true
  validates :high_price, presence: true
  validates :low_price, presence: true
  validates :close_price, presence: true

  def self.download_nikkei_average_html(year, month, missing_only = false)
    url = "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=#{year}&month=#{month}"
    file_name = "nikkei_average_#{year}_#{format("%02d", month)}.html"

    keys = Stock._download_with_get(url, file_name, missing_only)
  end

  def self.get_nikkei_averages(object_key)
    bucket = Stock._get_s3_bucket
    html = bucket.object(object_key).get.body

    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")

    price_lines = doc.xpath("//tr[not(contains(@class, 'list-header'))]")

    nikkei_averages = []
    price_lines.each do |price_line|
      nikkei_average = NikkeiAverage.new(
        date: Date.parse(price_line.xpath("td")[0].content),
        opening_price: price_line.xpath("td")[1].content.delete(",").to_d,
        high_price: price_line.xpath("td")[2].content.delete(",").to_d,
        low_price: price_line.xpath("td")[3].content.delete(",").to_d,
        close_price: price_line.xpath("td")[4].content.delete(",").to_d
      )
      raise nikkei_average.errors.messages.to_s if nikkei_average.invalid?

      nikkei_averages << nikkei_average
    end

    nikkei_averages
  end

  def self.import(nikkei_averages)
    raise "not implemented"
  end

end
