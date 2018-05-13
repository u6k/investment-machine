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

  def self.get_feed(ticker_symbol, object_key)
    bucket = Stock._get_s3_bucket
    feed = bucket.object(object_key).get.body

    doc = Nokogiri::XML.parse(feed, nil, "UTF-8")
    doc.remove_namespaces!

    feed_id = doc.xpath("/feed/id").text
    raise "Invalid feed" if not feed_id == "http://resource.ufocatch.com/atom/edinetx/query/#{ticker_symbol}"

    entries = doc.xpath("/feed/entry").select { |entry| entry.xpath("link[@type='application/zip']").length > 0 }

    wertpapier_reports = entries.map do |entry|
      wertpapier_report = WertpapierReport.new(
        ticker_symbol: ticker_symbol,
        entry_id: entry.xpath("id").text,
        title: entry.xpath("title").text,
        content_type: entry.xpath("link[@type='application/zip']")[0]["type"],
        url: entry.xpath("link[@type='application/zip']")[0]["href"],
        entry_updated: DateTime.iso8601(entry.xpath("updated").text)
      )
      raise wertpapier_report.errors.messages.to_s if wertpapier_report.invalid?

      wertpapier_report
    end
  end

  def self.import_feed(wertpapier_reports)
    raise "TODO" # TODO
  end

end
