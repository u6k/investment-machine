require "nokogiri"
require "active_record"
require "activerecord-import"
require "crawline"

module InvestmentStocks::Crawler::Parser
  class NikkeiAverageIndexParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentStocks::Crawler::AppLogger.get_logger
      @logger.debug("NikkeiAverageIndexParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      true
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

      @related_links = []

      doc.xpath("//div[@class='col-sm-2'][1]/select/option").map do |option|
        @logger.debug("NikkeiAverageIndexParser#_parse: option=#{option}")

        y = option["value"]
        (1..12).map do |m|
          @related_links << "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=#{y}&month=#{m}"
        end
      end
    end
  end

  class NikkeiAverageDataParser < Crawline::BaseParser
    def initialize(url, data)
      @logger = InvestmentStocks::Crawler::AppLogger.get_logger
      @logger.debug("NikkeiAverageDataParser#initialize: start: url=#{url}, data.nil?=#{data.nil?}")

      @url = url
      @data = data

      _parse
    end

    def redownload?
      @logger.debug("NikkeiAverageDataParser#redownload?: start: now=#{Time.now}, target_month=#{@target_month}")

      (Time.now - @target_month) < (60 * 24 * 60 * 60)
    end

    def valid?
      @logger.debug("NikkeiAverageDataParser#valid?: start: prices.empty?=#{@prices.empty?}")

      (not @prices.empty?)
    end

    def related_links
    end

    def parse(context)
      @logger.debug("NikkeiAverageDataParser#parse: start")

      return if not valid?

      ActiveRecord::Base.transaction do
        InvestmentStocks::Crawler::Model::NikkeiAverage.where(date: Time.new(@prices[0].date.year, @prices[0].date.month, 1)..(Time.new(@prices[0].date.year, @prices[0].date.month + 1, 1) - 24 * 60 * 60)).destroy_all
        @logger.debug("NikkeiAverageDataParser#parse: NikkeiAverage(year=#{@prices[0].date.year}, month=#{@prices[0].date.month}) destroy all")

        InvestmentStocks::Crawler::Model::NikkeiAverage.import(@prices)
        @logger.debug("NikkeiAverageDataParser#parse: NikkeiAverage(count: #{@prices.count}) saved")
      end
    end

    private

    def _parse
      @logger.debug("NikkeiAverageDataParser#_parse: start")

      doc = Nokogiri::HTML.parse(@data["response_body"], nil, "UTF-8")

      @prices = doc.xpath("//tr[not(contains(@class, 'list-header'))]").map do |tr|
        @logger.debug("NikkeiAverageDataParser#_parse: tr=#{tr}")

        price = InvestmentStocks::Crawler::Model::NikkeiAverage.new

        list_date_parts = tr.at_xpath("td[1]").text.split(".")
        price.date = Time.local(list_date_parts[0].to_i, list_date_parts[1].to_i, list_date_parts[2].to_i, 0, 0, 0)

        list_value = tr.at_xpath("td[2]").text
        price.open_price = (list_value == "-" ? nil : list_value.gsub(/,/, '').to_f)

        list_value = tr.at_xpath("td[3]").text
        price.high_price = (list_value == "-" ? nil : list_value.gsub(/,/, '').to_f)

        list_value = tr.at_xpath("td[4]").text
        price.low_price = (list_value == "-" ? nil : list_value.gsub(/,/, '').to_f)

        list_value = tr.at_xpath("td[5]").text
        price.close_price = (list_value == "-" ? nil : list_value.gsub(/,/, '').to_f)

        price
      end

      if not @prices.empty?
        @target_month = Time.local(@prices[0].date.year, @prices[0].date.month, 1, 0, 0, 0)
      end
    end
  end
end

module InvestmentStocks::Crawler::Model
  class NikkeiAverage < ActiveRecord::Base
    validates :date, uniqueness: true
  end
end

