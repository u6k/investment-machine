class WertpapierReport < ApplicationRecord

  validates :ticker_symbol, presence: true, format: { with: /\d{4}/i }
  validates :entry_id, presence: true, format: { with: /.+/i }
  validates :title, presence: true, format: { with: /.+/i }
  validates :content_type, presence: true, format: { with: /.+/i }
  validates :entry_updated, presence: true

  def self.build_feed_file_name(ticker_symbol)
    "wertpapier_feed_#{ticker_symbol}.atom"
  end

  def self.download_feed(ticker_symbol)
    url = "http://resource.ufocatch.com/atom/edinetx/query/#{ticker_symbol}"

    data = Stock._download_with_get(url)
    wertpapier_reports = parse_feed(ticker_symbol, data)

    { data: data, wertpapier_reports: wertpapier_reports }
  end

  def self.put_feed(ticker_symbol, data)
    file_name = build_feed_file_name(ticker_symbol)

    bucket = Stock._get_s3_bucket
    Stock._put_s3_object(bucket, file_name, data)
  end

  def self.get_feed(ticker_symbol)
    file_name = build_feed_file_name(ticker_symbol)

    bucket = Stock._get_s3_bucket
    Stock._get_s3_object(bucket, file_name)
  end

  def self.parse_feed(ticker_symbol, feed)
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
    wertpapier_report_ids = nil

    WertpapierReport.transaction do
      wertpapier_report_ids = wertpapier_reports.map do |wertpapier_report|
        wrs = WertpapierReport.where("ticker_symbol = :ticker_symbol and entry_id = :entry_id", ticker_symbol: wertpapier_report.ticker_symbol, entry_id: wertpapier_report.entry_id)
        if wrs.empty?
          wr = WertpapierReport.new(
            ticker_symbol: wertpapier_report.ticker_symbol,
            entry_id: wertpapier_report.entry_id,
            title: wertpapier_report.title,
            content_type: wertpapier_report.content_type,
            url: wertpapier_report.url,
            entry_updated: wertpapier_report.entry_updated
          )
        else
          wr = wrs[0]
          wr.title = wertpapier_report.title
          wr.content_type = wertpapier_report.content_type
          wr.url = wertpapier_report.url
          wr.entry_updated = wertpapier_report.entry_updated
        end

        wr.save!
        wr.id
      end
    end

    wertpapier_report_ids
  end

  def self.build_wertpapier_zip_file_name(ticker_symbol, entry_id)
    "wertpapier_zip_#{ticker_symbol}_#{entry_id}.zip"
  end

  def self.download_wertpapier_zip(ticker_symbol, entry_id, missing_only = false)
    wertpapier_report = WertpapierReport.where("ticker_symbol = :ticker_symbol and entry_id = :entry_id", ticker_symbol: ticker_symbol, entry_id: entry_id).first
    url = wertpapier_report.url
    file_name = build_wertpapier_zip_file_name(ticker_symbol, entry_id)

    bucket = Stock._get_s3_bucket
    if bucket.object(file_name) && missing_only
      nil
    else
      data = Stock._download_with_get(url)
      { data: data }
    end
  end

  def self.put_wertpapier_zip(ticker_symbol, entry_id, data)
    file_name = build_wertpapier_zip_file_name(ticker_symbol, entry_id)

    bucket = Stock._get_s3_bucket
    Stock._put_s3_object(bucket, file_name, data)
  end

  def self.get_wertpapier_zip(ticker_symbol, entry_id)
    file_name = build_wertpapier_zip_file_name(ticker_symbol, entry_id)

    bucket = Stock._get_s3_bucket
    Stock._get_s3_object(bucket, file_name)
  end

end
