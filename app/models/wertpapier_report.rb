class WertpapierReport < ApplicationRecord

  validates :ticker_symbol, presence: true, format: { with: /\d{4}/i }
  validates :entry_id, presence: true, format: { with: /.+/i }
  validates :title, presence: true, format: { with: /.+/i }
  validates :content_type, presence: true, format: { with: /.+/i }
  validates :entry_updated, presence: true

  def self.download_feed(ticker_symbol)
    url = "http://resource.ufocatch.com/atom/edinetx/query/#{ticker_symbol}"
    file_name = "wertpapier_feed_#{ticker_symbol}.atom"

    keys = Stock._download_with_get(url, file_name, false)
  end

end
