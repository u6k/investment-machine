#class NikkeiAverage < ApplicationRecord
#  validates :date, presence: true
#  validates :opening_price, presence: true
#  validates :high_price, presence: true
#  validates :low_price, presence: true
#  validates :close_price, presence: true
#
#  def self.build_nikkei_average_html_file_name(year, month)
#    file_name = "nikkei_average_#{year}_#{format("%02d", month)}.html"
#  end
#
#  def self.download_nikkei_average_html(year, month, missing_only = false)
#    url = "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=#{year}&month=#{month}"
#    file_name = build_nikkei_average_html_file_name(year, month)
#
#    bucket = Stock._get_s3_bucket
#    if missing_only && bucket.object(file_name).exists?
#      nil
#    else
#      data = Stock._download_with_get(url)
#      nikkei_averages = parse_nikkei_average_html(data)
#
#      { data: data, nikkei_averages: nikkei_averages }
#    end
#  end
#
#  def self.put_nikkei_average_html(year, month, data)
#    file_name = build_nikkei_average_html_file_name(year, month)
#
#    bucket = Stock._get_s3_bucket
#    Stock._put_s3_object(bucket, file_name, data)
#  end
#
#  def self.get_nikkei_average_html(year, month)
#    file_name = build_nikkei_average_html_file_name(year, month)
#
#    bucket = Stock._get_s3_bucket
#    Stock._get_s3_object(bucket, file_name)
#  end
#
#  def self.parse_nikkei_average_html(html)
#    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")
#
#    price_lines = doc.xpath("//tr[not(contains(@class, 'list-header'))]")
#
#    nikkei_averages = []
#    price_lines.each do |price_line|
#      nikkei_average = NikkeiAverage.new(
#        date: Date.parse(price_line.xpath("td")[0].content),
#        opening_price: price_line.xpath("td")[1].content.delete(",").to_d,
#        high_price: price_line.xpath("td")[2].content.delete(",").to_d,
#        low_price: price_line.xpath("td")[3].content.delete(",").to_d,
#        close_price: price_line.xpath("td")[4].content.delete(",").to_d
#      )
#      raise nikkei_average.errors.messages.to_s if nikkei_average.invalid?
#
#      nikkei_averages << nikkei_average
#    end
#
#    nikkei_averages
#  end
#
#  def self.import(nikkei_averages)
#    nikkei_average_ids = []
#
#    NikkeiAverage.transaction do
#      nikkei_averages.each do |nikkei_average|
#        n = NikkeiAverage.find_by(date: nikkei_average.date)
#
#        if n.nil?
#          n = NikkeiAverage.new(
#            date: nikkei_average.date,
#            opening_price: nikkei_average.opening_price,
#            high_price: nikkei_average.high_price,
#            low_price: nikkei_average.low_price,
#            close_price: nikkei_average.close_price
#          )
#        else
#          n.opening_price = nikkei_average.opening_price
#          n.high_price = nikkei_average.high_price
#          n.low_price = nikkei_average.low_price
#          n.close_price = nikkei_average.close_price
#        end
#
#        n.save!
#        nikkei_average_ids << n.id
#      end
#    end
#
#    nikkei_average_ids
#  end
#
#end
