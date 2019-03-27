require "nokogiri"
require "crawline"

module InvestmentMachine::Parser
  class NikkeiAverageIndexParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentMachine::AppLogger.get_logger
      @logger.debug("NikkeiAverageIndexParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      @logger.debug("NikkeiAverageIndexParser#redownload?: start: now=#{Time.now}, downloaded_timestamp=#{@data["downloaded_timestamp"]}")

      (Time.now - @data["downloaded_timestamp"]) > (23 * 60 * 60)
    end

    def valid?
      @logger.debug("NikkeiAverageIndexParser#valid?")

      (not @related_links.nil?)
    end

    def related_links
      @related_links
    end

    def parse(context)
    end

    private

    def _parse
      @logger.debug("NikkeiAverageIndexParser#_parse: start")

      doc = Nokogiri::HTML.parse(@data["response_body"], nil, "UTF-8")

      @related_links = doc.xpath("//div[@class='col-sm-2'][1]/select/option").map do |option|
        @logger.debug("NikkeiAverageIndexParser#_parse: option=#{option}")

        y = option["value"]
        (1..12).map do |m|
          "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=#{y}&month=#{m}"
        end
      end
    end
  end
end

