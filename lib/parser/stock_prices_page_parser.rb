require "nokogiri"
require "crawline"

module InvestmentMachine::Parser
  class StockPricesPageParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentMachine::AppLogger.get_logger
      @logger.debug("StockPricesPageParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      #_parse
    end
  end
end

