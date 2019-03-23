require "nokogiri"
require "crawline"

module InvestmentMachine::Parser
  class StockListPageParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentMachine::AppLogger.get_logger
      @logger.debug("StockListPageParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      @logger.debug("StockListPageParser#redownload?: start: now=#{Time.now}, downloaded_timestamp=#{@data["downloaded_timestamp"]}")

      (Time.now - @data["downloaded_timestamp"]) > (23 * 60 * 60)
    end

    def valid?
      @logger.debug("StockListPageParser#valid?")

      @related_links.select { |url| url.match(/\/stock\/\d{4}\//) }.size > 0
    end

    def related_links
      (valid? ? @related_links : nil)
    end

    def parse(context)
    end

    private

    def _parse
      @logger.debug("StockListPageParser#_parse: start")

      doc = Nokogiri::HTML.parse(@data["response_body"], nil, "UTF-8")

      @related_links = doc.xpath("//ul[@class='pager']/li/a").map do |a|
        @logger.debug("StockListPageParser#_parse: pager: a=#{a}")

        URI.join(@url, a["href"]).to_s
      end

      @related_links += doc.xpath("//table[@class='stock_table']/tbody/tr/td/a").map do |a|
        @logger.debug("StockListPageParser#_parse: stock_table: a=#{a}")

        a["href"]
      end
    end
  end
end

