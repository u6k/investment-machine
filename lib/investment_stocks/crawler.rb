require "thor"
require "json"

require "investment_stocks/crawler/version"
require "investment_stocks/crawler/parser/stock_list_page_parser"
require "investment_stocks/crawler/parser/stock_prices_page_parser"
require "investment_stocks/crawler/parser/edinet_feed_parser"
require "investment_stocks/crawler/parser/xbrl_zip_parser"
require "investment_stocks/crawler/parser/nikkei_average_parser"
require "investment_stocks/crawler/parser/topix_parser"
require "investment_stocks/crawler/parser/djia_parser"

module InvestmentStocks::Crawler
  class CLI < Thor
    desc "version", "Display version"
    def version
      puts InvestmentStocks::Crawler::VERSION
    end

    desc "crawl", "Crawl stocks"
    method_option :s3_access_key
    method_option :s3_secret_key
    method_option :s3_region, default: "us-east-1"
    method_option :s3_bucket
    method_option :s3_endpoint, default: "https://s3.amazonaws.com"
    method_option :s3_force_path_style, default: false
    method_option :s3_object_name_prefix, default: nil
    method_option :db_database
    method_option :db_host, default: "localhost"
    method_option :db_port, default: "5432"
    method_option :db_username
    method_option :db_password
    method_option :db_sslmode, default: nil
    method_option :interval, default: "1.0"
    method_option :entrypoint_url, default: "https://kabuoji3.com/stock/"
    def crawl
      setup_db_connection(options.db_database, options.db_host, options.db_port, options.db_username, options.db_password, options.db_sslmode)

      engine = setup_crawline_engine(options.s3_access_key, options.s3_secret_key, options.s3_region, options.s3_bucket, options.s3_endpoint, options.s3_force_path_style, options.s3_object_name_prefix, options.interval)

      engine.crawl(options.entrypoint_url)
    end

    desc "parse", "Parse stocks"
    method_option :s3_access_key
    method_option :s3_secret_key
    method_option :s3_region, default: "us-east-1"
    method_option :s3_bucket
    method_option :s3_endpoint, default: "https://s3.amazonaws.com"
    method_option :s3_force_path_style, default: false
    method_option :s3_object_name_prefix, default: nil
    method_option :db_database
    method_option :db_host, default: "localhost"
    method_option :db_port, default: "5432"
    method_option :db_username
    method_option :db_password
    method_option :db_sslmode, default: nil
    method_option :entrypoint_url, default: "https://kabuoji3.com/stock/"
    def parse
      setup_db_connection(options.db_database, options.db_host, options.db_port, options.db_username, options.db_password, options.db_sslmode)

      engine = setup_crawline_engine(options.s3_access_key, options.s3_secret_key, options.s3_region, options.s3_bucket, options.s3_endpoint, options.s3_force_path_style, options.s3_object_name_prefix, 1.0)

      engine.parse(options.entrypoint_url)
    end

    private

    def setup_crawline_engine(s3_access_key, s3_secret_key, s3_region, s3_bucket, s3_endpoint, s3_force_path_style, s3_object_name_prefix, interval)
      downloader = Crawline::Downloader.new("investment-stocks-crawler/#{InvestmentStocks::Crawler::VERSION} (https://github.com/u6k/investment-stocks-crawler)")

      repo = Crawline::ResourceRepository.new(s3_access_key, s3_secret_key, s3_region, s3_bucket, s3_endpoint, s3_force_path_style, s3_object_name_prefix)
      @repo = repo

      parsers = {
        /^https:\/\/kabuoji3\.com\/stock\/(\?page=\d{1,2})?$/ => Parser::StockListPageParser,
        /^https:\/\/kabuoji3\.com\/stock\/\d{4}\/(\d+\/)?$/ => Parser::StockPricesPageParser,
        /^https:\/\/resource\.ufocatch\.com\/atom\/(edinetx|tdnetx\/)(\d+)?$/ => Parser::EdinetFeedParser,
        /^https:\/\/resource\.ufocatch\.com\/data\/(edinet|tdnet)\/\w+$/ => Parser::XbrlZipParser,
        /^https:\/\/indexes\.nikkei\.co\.jp\/nkave\/archives.*$/ => Parser::NikkeiAverageIndexParser,
        /^https:\/\/indexes\.nikkei\.co\.jp\/nkave\/statistics.*$/ => Parser::NikkeiAverageDataParser,
        /^https:\/\/quotes\.wsj\.com\/index\/JP\/XTKS\/I0000\/historical-prices\/$/ => Parser::TopixIndexPageParser,
        /^https:\/\/quotes\.wsj\.com\/index\/JP\/XTKS\/I0000\/historical-prices\/.+$/ => Parser::TopixCsvParser,
        /^https:\/\/quotes\.wsj\.com\/index\/DJIA\/historical-prices\/$/ => Parser::DjiaIndexPageParser,
        /^https:\/\/quotes\.wsj\.com\/index\/DJIA\/historical-prices\/.+$/ => Parser::DjiaCsvParser,
      }

      engine = Crawline::Engine.new(downloader, repo, parsers, interval.to_i)
    end

    def setup_db_connection(db_database, db_host, db_port, db_username, db_password, db_sslmode)
      db_config = {
        adapter: "postgresql",
        database: db_database,
        host: db_host,
        port: db_port,
        username: db_username,
        password: db_password,
        sslmode: db_sslmode
      }

      ActiveRecord::Base.establish_connection db_config
    end
  end

  class AppLogger
    @@logger = nil

    def self.get_logger
      if @@logger.nil?
        @@logger = Logger.new(STDOUT)
        @@logger.level = ENV["APP_LOGGER_LEVEL"] if ENV.has_key?("APP_LOGGER_LEVEL")
      end

      @@logger
    end
  end
end
