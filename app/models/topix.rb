require "csv"

class Topix < ApplicationRecord
  validates :date, presence: true
  validates :opening_price, presence: true
  validates :high_price, presence: true
  validates :low_price, presence: true
  validates :close_price, presence: true

  def self.download_topix_csv(date_from, date_to)
    interval_day = ((date_to - 1) - date_from).to_i
    url = "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=#{interval_day}&range_days=#{interval_day}&startDate=#{date_from.strftime('%m/%d/%Y')}&endDate=#{(date_to - 1).strftime('%m/%d/%Y')}"
    file_name = "topix_#{date_from.strftime('%Y%m%d')}_#{date_to.strftime('%Y%m%d')}.csv"

    keys = Stock._download_with_get(url, file_name, false)
  end

  def self.get_topixes(object_key)
    bucket = Stock._get_s3_bucket
    csv = bucket.object(object_key).get.body

    topixes = []
    CSV.parse(csv) do |line|
      if line[0].match(/^[0-9]{2}\/[0-9]{2}\/[0-9]{2}$/)
        topix = Topix.new(
          date: Date.strptime(line[0], "%m/%d/%y"),
          opening_price: line[1].to_d,
          high_price: line[2].to_d,
          low_price: line[3].to_d,
          close_price: line[4].to_d
        )
        raise topix.errors.messages.to_s if topix.invalid?

        topixes << topix
      end
    end

    topixes
  end

  def self.import(topixes)
    topix_ids = []

    Topix.transaction do
      topixes.each do |topix|
        t = Topix.find_by(date: topix.date)

        if t.nil?
          t = Topix.new(
            date: topix.date,
            opening_price: topix.opening_price,
            high_price: topix.high_price,
            low_price: topix.low_price,
            close_price: topix.close_price
          )
        else
          t.opening_price = topix.opening_price
          t.high_price = topix.high_price
          t.low_price = topix.low_price
          t.close_price = topix.close_price
        end

        t.save!
        topix_ids << t.id
      end
    end

    topix_ids
  end

end
