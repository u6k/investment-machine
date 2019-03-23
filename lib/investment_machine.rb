require "thor"

require "investment_machine/version"

module InvestmentMachine
  class CLI < Thor
    desc "version", "Display version"
    def version
      puts InvestmentMachine::VERSION
    end
  end
end

