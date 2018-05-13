class WertpapierReport < ApplicationRecord

  validates :ticker_symbol, presence: true, format: { with: /\d{4}/i }
  validates :entry_id, presence: true, format: { with: /.+/i }
  validates :title, presence: true, format: { with: /.+/i }
  validates :content_type, presence: true, format: { with: /.+/i }
  validates :entry_updated, presence: true

  def self.download_feed(ticker_symbol)
    raise "TODO" # TODO
  end

end
