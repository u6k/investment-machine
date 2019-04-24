require "nokogiri"
require "crawline"

module InvestmentStocks::Crawler::Parser
  class EdinetFeedParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentStocks::Crawler::AppLogger.get_logger
      @logger.debug("EdinetFeedParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      @logger.debug("EdinetFeedParser#redownload?: start: now=#{Time.now}, downloaded_timestamp=#{@data["downloaded_timestamp"]}")

      (Time.now - @data["downloaded_timestamp"]) > (60 * 60)
    end

    def valid?
      @logger.debug("EdinetFeedParser#valid?")

      (not @related_links.empty?)
    end

    def related_links
      (valid? ? @related_links : nil)
    end

    def parse(context)
    end

    private

    def _parse
      @logger.debug("EdinetFeedParser#_parse: start")

      doc = Nokogiri::XML.parse(@data["response_body"], nil, "UTF-8")

      namespaces = { "xmlns" => "http://www.w3.org/2005/Atom" }

      @related_links = doc.xpath("//xmlns:link[@rel='next']", namespaces).map do |link|
        @logger.debug("EdinetFeedParser#_parse: next: link=#{link}")

        link["href"]
      end

      @related_links += doc.xpath("//xmlns:entry/xmlns:link[@type='application/zip']", namespaces).map do |link|
        @logger.debug("EdinetFeedParser#_parse: zip: link=#{link}")

        link["href"]
      end
    end
  end
end

