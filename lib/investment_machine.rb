require "thor"

require "investment_machine/version"
require "parser/stock_list_page_parser"

module InvestmentMachine
  class CLI < Thor
    desc "version", "Display version"
    def version
      puts InvestmentMachine::VERSION
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

