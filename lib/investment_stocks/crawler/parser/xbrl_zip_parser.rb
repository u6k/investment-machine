require "crawline"
require "zip"

module InvestmentStocks::Crawler::Parser
  class XbrlZipParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentStocks::Crawler::AppLogger.get_logger
      @logger.debug("XbrlZipParser#initialize: start: url=#{url}, data.size=#{data.size}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      false
    end

    def valid?
      (not @entries.empty?)
    end

    def related_links
    end

    def parse(context)
      context[@feed_id] = {
        "entries" => @entries
      }
    end

    private

    def _parse
      @logger.debug("XbrlZipParser#_parse: start")

      @feed_id = @url.match(/^https:\/\/resource\.ufocatch\.com\/data\/(edinet|tdnet)\/(.+)$/) do |matches|
        @logger.debug("XbrlZipParser#_parse: feed_id: matches=#{matches}")

        matches[2]
      end

      @entries = []

      Zip::File.open_buffer(StringIO.new(@data["response_body"])) do |zip|
        zip.each do |entry|
          @logger.debug("XbrlZipParser#_parse: zip: entry.name=#{entry.name}")

          @entries << entry.name
        end
      end
    end
  end
end

