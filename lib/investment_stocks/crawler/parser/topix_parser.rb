require "csv"
require "active_record"
require "activerecord-import"
require "crawline"

module InvestmentStocks::Crawler::Parser
  class TopixIndexPageParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentStocks::Crawler::AppLogger.get_logger
      @logger.debug("TopixIndexPageParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @data = data
    end

    def redownload?
      true
    end

    def valid?
      true
    end

    def related_links
      (1990..@data["downloaded_timestamp"].year).map do |year|
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/#{year}&endDate=12/31/#{year}"
      end
    end

    def parse(context)
    end
  end

  class TopixCsvParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentStocks::Crawler::AppLogger.get_logger
      @logger.debug("TopixCsvParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      @logger.debug("TopixCsvParser#redownload?: start: now=#{Time.now}, target_year=#{@target_year}")

      (Time.now.year - @prices[0].date.year) < 2
    end

    def valid?
      (not @prices.empty?)
    end

    def related_links
    end

    def parse(context)
      @logger.debug("TopixCsvParser#parse: start")

      ActiveRecord::Base.transaction do
        InvestmentStocks::Crawler::Model::Topix.where(date: Time.new(@prices[0].date.year, 1, 1)..Time.new(@prices[0].date.year, 12, 31, 23, 59, 59)).destroy_all
        @logger.debug("TopixCsvParser#parse: Topix(year: #{@prices[0].date.year}) destroy all")

        InvestmentStocks::Crawler::Model::Topix.import(@prices)
        @logger.debug("TopixCsvParser#parse: Topix(count: #{@prices.count}) saved")
      end
    end

    private

    def _parse
      @logger.debug("TopixCsvParser#_parse: start")

      @prices = CSV.parse(@data["response_body"], headers: true).map do |row|
        @logger.debug("TopixCsvParser#_parse: row=#{row}")
        date_parts = row[0].split("/")

        price = InvestmentStocks::Crawler::Model::Topix.new
        price.date = Time.local(date_parts[2].to_i + (date_parts[2].to_i > 89 ? 1900 : 2000), date_parts[0].to_i, date_parts[1].to_i)
        price.open_price = row[1].to_f
        price.high_price = row[2].to_f
        price.low_price = row[3].to_f
        price.close_price = row[4].to_f

        price
      end
    end
  end
end

module InvestmentStocks::Crawler::Model
  class Topix < ActiveRecord::Base
    validates :date, uniqueness: true
  end
end

