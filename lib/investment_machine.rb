require "thor"

require "investment_machine/version"
require "parser/stock_list_page_parser"
require "parser/stock_prices_page_parser"
require "parser/edinet_feed_parser"
require "parser/xbrl_zip_parser"

module InvestmentMachine
  class CLI < Thor
    desc "version", "Display version"
    def version
      puts InvestmentMachine::VERSION
    end

    desc "crawl", "Crawl stocks"
    method_option :s3_access_key
    method_option :s3_secret_key
    method_option :s3_region, default: "us-east-1"
    method_option :s3_bucket
    method_option :s3_endpoint, default: "https://s3.amazonaws.com"
    method_option :s3_force_path_style, default: false
    method_option :interval, default: "1.0"
    method_option :entrypoint_url, default: "https://kabuoji3.com/stock/"
    def crawl
      downloader = Crawline::Downloader.new("investment-machine/#{InvestmentMachine::VERSION} (https://github.com/u6k/investment-machine)")

      repo = Crawline::ResourceRepository.new(options.s3_access_key, options.s3_secret_key, options.s3_region, options.s3_bucket, options.s3_endpoint, options.s3_force_path_style, nil)

      parsers = {
        /^https:\/\/kabuoji3\.com\/stock\/(\?page=\d{1,2})?$/ => Parser::StockListPageParser,
        /^https:\/\/kabuoji3\.com\/stock\/\d{4}\/(\d+\/)?$/ => Parser::StockPricesPageParser,
        /^https:\/\/resource\.ufocatch\.com\/atom\/(edinetx|tdnetx)(\/\d+)?$/ => Parser::EdinetFeedParser,
        /^https:\/\/resource\.ufocatch\.com\/data\/(edinet|tdnet)\/\w+$/ => Parser::XbrlZipParser,
      }

      engine = Crawline::Engine.new(downloader, repo, parsers, options.interval.to_i)

      engine.crawl(options.entrypoint_url)
    end
  end

  class AppLogger
    @@logger = nil

    def self.get_logger
      if @@logger.nil?
        @@logger = Logger.new(STDOUT)
        @@logger.level = ENV["INVESTMENT_LOGGER_LEVEL"] if ENV.has_key?("INVESTMENT_LOGGER_LEVEL")
      end

      @@logger
    end
  end
end

