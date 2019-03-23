require "nokogiri"
require "crawline"

module InvestmentMachine::Parser
  class StockPricesPageParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentMachine::AppLogger.get_logger
      @logger.debug("StockPricesPageParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      @logger.debug("StockPricesPageParser#redownload?: start: now=#{Time.now}, downloaded_timestamp=#{@data["downloaded_timestamp"]}, page_date=#{@stock_prices[0]["date"]}")

      return false if (Time.now - @data["downloaded_timestamp"]) < (23 * 60 * 60)

      (Time.now - @stock_prices[0]["date"]) < (365 * 24 * 60 * 60)
    end

    def valid?
      @logger.debug("StockPricesPageParser#valid?")

      (not @stock_prices.empty?)
    end

    def related_links
      (valid? ? @related_links : nil)
    end

    def parse(context)
      context[@ticker_symbol] = {
        "ticker_symbol" => @ticker_symbol,
        "company_name" => @company_name,
        "market" => @market,
        "stock_prices" => @stock_prices
      }
    end

    private

    def _parse
      @logger.debug("StockPricesPageParser#_parse")

      doc = Nokogiri::HTML.parse(@data["response_body"], nil, "UTF-8")

      doc.xpath("//meta[@name='keywords']").each do |meta|
        @logger.debug("StockPricesPageParser#_parse: meta=#{meta}")

        @ticker_symbol = meta["content"].split(",")[0]
        @company_name = meta["content"].split(",")[1]
        @market = meta["content"].split(",")[2]
      end

      @related_links = doc.xpath("//ul[contains(@class, 'stock_yselect')]/li/a").map do |a|
        @logger.debug("StockPricesPageParser#_parse: a=#{a}")

        a["href"]
      end

      @stock_prices = doc.xpath("//table[@class='stock_table stock_data_table']/tbody/tr").map do |tr|
        @logger.debug("StockPricesPageParser#_parse: tr=#{tr}")

        {
          "date" => Time.local(tr.at_xpath("td[1]").text[0..3], tr.at_xpath("td[1]").text[5..6], tr.at_xpath("td[1]").text[8..9]),
          "opening_price" => tr.at_xpath("td[2]").text.to_i,
          "high_price" => tr.at_xpath("td[3]").text.to_i,
          "low_price" => tr.at_xpath("td[4]").text.to_i,
          "close_price" => tr.at_xpath("td[5]").text.to_i,
          "turnover" => tr.at_xpath("td[6]").text.to_i,
          "adjustment_value" => tr.at_xpath("td[7]").text.to_i
        }
      end
      @stock_prices += doc.xpath("//table[@class='stock_table stock_data_table']/tr").map do |tr|
        @logger.debug("StockPricesPageParser#_parse: tr=#{tr}")

        {
          "date" => Time.local(tr.at_xpath("td[1]").text[0..3], tr.at_xpath("td[1]").text[5..6], tr.at_xpath("td[1]").text[8..9]),
          "opening_price" => tr.at_xpath("td[2]").text.to_i,
          "high_price" => tr.at_xpath("td[3]").text.to_i,
          "low_price" => tr.at_xpath("td[4]").text.to_i,
          "close_price" => tr.at_xpath("td[5]").text.to_i,
          "turnover" => tr.at_xpath("td[6]").text.to_i,
          "adjustment_value" => tr.at_xpath("td[7]").text.to_i
        }
      end

      @stock_prices.sort! do |a, b|
        b["date"] <=> a["date"]
      end
    end
  end
end

