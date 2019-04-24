require "nokogiri"
require "active_record"
require "crawline"

module InvestmentStocks::Crawler::Parser
  class StockPricesPageParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentStocks::Crawler::AppLogger.get_logger
      @logger.debug("StockPricesPageParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      @logger.debug("StockPricesPageParser#redownload?: start: now=#{Time.now}, downloaded_timestamp=#{@data["downloaded_timestamp"]}, page_date=#{@stock_prices[0].date}")

      return false if (Time.now - @data["downloaded_timestamp"]) < (23 * 60 * 60)

      (Time.now - @stock_prices[0].date) < (365 * 24 * 60 * 60)
    end

    def valid?
      @logger.debug("StockPricesPageParser#valid?")

      (not @stock_prices.empty?)
    end

    def related_links
      (valid? ? @related_links : nil)
    end

    def parse(context)
      @company.save! if @company.valid?

      @stock_prices.each do |stock_price|
        stock_price.save! if stock_price.valid?
      end
    end

    private

    def _parse
      @logger.debug("StockPricesPageParser#_parse: start")

      doc = Nokogiri::HTML.parse(@data["response_body"], nil, "UTF-8")

      doc.xpath("//meta[@name='keywords']").each do |meta|
        @logger.debug("StockPricesPageParser#_parse: meta=#{meta}")

        @company = InvestmentStocks::Crawler::Model::Company.new
        @company.ticker_symbol = meta["content"].split(",")[0]
        @company.name = meta["content"].split(",")[1]
        @company.market = meta["content"].split(",")[2]
      end

      @related_links = doc.xpath("//ul[contains(@class, 'stock_yselect')]/li/a").map do |a|
        @logger.debug("StockPricesPageParser#_parse: a=#{a}")

        a["href"]
      end

      @stock_prices = doc.xpath("//table[@class='stock_table stock_data_table']/tbody/tr").map do |tr|
        @logger.debug("StockPricesPageParser#_parse: tr=#{tr}")

        stock_price = InvestmentStocks::Crawler::Model::StockPrice.new
        stock_price.ticker_symbol = @company.ticker_symbol
        stock_price.date = Time.local(tr.at_xpath("td[1]").text[0..3], tr.at_xpath("td[1]").text[5..6], tr.at_xpath("td[1]").text[8..9])
        stock_price.opening_price = tr.at_xpath("td[2]").text.to_i
        stock_price.high_price = tr.at_xpath("td[3]").text.to_i
        stock_price.low_price = tr.at_xpath("td[4]").text.to_i
        stock_price.close_price = tr.at_xpath("td[5]").text.to_i
        stock_price.turnover = tr.at_xpath("td[6]").text.to_i
        stock_price.adjustment_value = tr.at_xpath("td[7]").text.to_i

        stock_price
      end
      @stock_prices += doc.xpath("//table[@class='stock_table stock_data_table']/tr").map do |tr|
        @logger.debug("StockPricesPageParser#_parse: tr=#{tr}")

        stock_price = InvestmentStocks::Crawler::Model::StockPrice.new
        stock_price.ticker_symbol = @company.ticker_symbol
        stock_price.date = Time.local(tr.at_xpath("td[1]").text[0..3], tr.at_xpath("td[1]").text[5..6], tr.at_xpath("td[1]").text[8..9])
        stock_price.opening_price = tr.at_xpath("td[2]").text.to_i
        stock_price.high_price = tr.at_xpath("td[3]").text.to_i
        stock_price.low_price = tr.at_xpath("td[4]").text.to_i
        stock_price.close_price = tr.at_xpath("td[5]").text.to_i
        stock_price.turnover = tr.at_xpath("td[6]").text.to_i
        stock_price.adjustment_value = tr.at_xpath("td[7]").text.to_i

        stock_price
      end

      @stock_prices.sort! do |a, b|
        b.date <=> a.date
      end
    end
  end
end

module InvestmentStocks::Crawler::Model
  class Company < ActiveRecord::Base
    validates :ticker_symbol, uniqueness: true
  end

  class StockPrice < ActiveRecord::Base
    validates :ticker_symbol, uniqueness: { scope: :date }
  end
end

