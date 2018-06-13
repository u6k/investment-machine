require "csv"

class DowJonesIndustrialAverage < ApplicationRecord
  validates :date, presence: true
  validates :opening_price, presence: true
  validates :high_price, presence: true
  validates :low_price, presence: true
  validates :close_price, presence: true

  def self.download_djia_csv(date_from, date_to)
    interval_day = ((date_to - 1) - date_from).to_i
    url = "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=#{interval_day}&range_days=#{interval_day}&startDate=#{date_from.strftime('%m/%d/%Y')}&endDate=#{(date_to - 1).strftime('%m/%d/%Y')}"

    data = Stock._download_with_get(url)
    djias = get_djias(data)

    { data: data, djias: djias }
  end

  def self.put_djia_csv(bucket, date_from, date_to, data)
    file_name = "djia_#{date_from.strftime('%Y%m%d')}_#{date_to.strftime('%Y%m%d')}.csv"

    object_original = bucket.object(file_name)
    object_original.put(body: data)

    object_backup = bucket.object(file_name + ".bak_" + DateTime.now.strftime("%Y%m%d-%H%M%S"))
    object_backup.put(body: data)

    { original: object_original.key, backup: object_backup.key }
  end

  def self.get_djias(csv)
    djias = []
    CSV.parse(csv) do |line|
      if line[0].match(/^[0-9]{2}\/[0-9]{2}\/[0-9]{2}$/)
        djia = DowJonesIndustrialAverage.new(
          date: Date.strptime(line[0], "%m/%d/%y"),
          opening_price: line[1].to_d,
          high_price: line[2].to_d,
          low_price: line[3].to_d,
          close_price: line[4].to_d
        )
        raise djia.errors.messages.to_s if djia.invalid?

        djias << djia
      end
    end

    djias
  end

  def self.import(djias)
    djia_ids = []

    Topix.transaction do
      djias.each do |djia|
        d = DowJonesIndustrialAverage.find_by(date: djia.date)

        if d.nil?
          d = DowJonesIndustrialAverage.new(
            date: djia.date,
            opening_price: djia.opening_price,
            high_price: djia.high_price,
            low_price: djia.low_price,
            close_price: djia.close_price
          )
        else
          d.opening_price = djia.opening_price
          d.high_price = djia.high_price
          d.low_price = djia.low_price
          d.close_price = djia.close_price
        end

        d.save!
        djia_ids << d.id
      end
    end

    djia_ids
  end

end
