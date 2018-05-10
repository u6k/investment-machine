require "open-uri"
require "nokogiri"
require "aws-sdk-s3"

namespace :crawl do
  desc "Crawler"

  task :download_stocks, [:missing_only] => :environment do |task, args|
    missing_only = (args.missing_only == "true")
    Rails.logger.info "download_stocks: start: missing_only=#{missing_only}"

    Rails.logger.info "download_index_page and get_page_links: start"
    keys = Stock.download_index_page(missing_only)
    page_links = Stock.get_page_links(keys[:original])
    Rails.logger.info "download_index_page and get_page_links: end: page_links.length=#{page_links.length}"

    page_links.each.with_index(1) do |page_link, page_link_index|
      Rails.logger.info "download_stock_list_page: start: #{page_link_index}/#{page_links.length}, page_link=#{page_link}"
      Stock.download_stock_list_page(page_link, missing_only)
      Rails.logger.info "download_stock_list_page: end"
    end

    Rails.logger.info "download_stocks: end"
  end

  task import_stocks: :environment do
    Rails.logger.info "import_stocks: start"

    Rails.logger.info "get_page_links: start"
    page_links = Stock.get_page_links("stock_list_index.html")
    Rails.logger.info "get_page_links: end: page_links.length=#{page_links.length}"

    page_links.each.with_index(1) do |page_link, page_link_index|
      Rails.logger.info "get_stocks and import: start: #{page_link_index}/#{page_links.length}: page_link=#{page_link}"
      stocks = Stock.get_stocks("stock_list_#{page_link}.html")
      Stock.import(stocks)
      Rails.logger.info "get_stocks and import: end: stocks.length=#{stocks.length}"
    end

    Rails.logger.info "import_stocks: end: Stock.all.length=#{Stock.all.length}"
  end

  task :download_stock_prices, [:ticker_symbol, :year, :missing_only] => :environment do |task, args|
    missing_only = (args.missing_only == "true")
    Rails.logger.info "download_stock_prices: start: ticker_symbol=#{args.ticker_symbol}, year=#{args.year}, missing_only=#{missing_only}"

    if args.ticker_symbol == "all"
      stocks = Stock.all
    else
      stocks = Stock.where("ticker_symbol = :ticker_symbol", ticker_symbol: args.ticker_symbol)
    end
    Rails.logger.info "target stocks.length=#{stocks.length}"

    ticker_symbol_years = []
    stocks.each.with_index(1) do |stock, stock_index|
      Rails.logger.info "foreach stock: start: #{stock_index}/#{stocks.length}: ticker_symbol=#{stock.ticker_symbol}"

      if args.year == "all"
        keys = Stock.download_stock_detail_page(stock.ticker_symbol, missing_only)
        years = Stock.get_years(keys[:original])
      else
        years = [args.year.to_i]
      end

      years.each do |year|
        ticker_symbol_years << { ticker_symbol: stock.ticker_symbol, year: year }
      end

      Rails.logger.info "ticker_symbol=#{stock.ticker_symbol}, years=#{years}"

      Rails.logger.info "foreach stock: end"
    end

    ticker_symbol_years.each.with_index(1) do |record, index|
      Rails.logger.info "download_stock_price_csv: start: #{index}/#{ticker_symbol_years.length}: ticker_symbol=#{record[:ticker_symbol]}, year=#{record[:year]}"
      StockPrice.download_stock_price_csv(record[:ticker_symbol], record[:year], missing_only)
      Rails.logger.info "download_stock_price_csv: end"
    end
  end

  task :import_stock_prices, [:ticker_symbol, :year] => :environment do |task, args|
    Rails.logger.info "import_stock_prices: start: ticker_symbol=#{args.ticker_symbol}, year=#{args.year}"

    if args.ticker_symbol == "all"
      stocks = Stock.all
    else
      stocks = Stock.where("ticker_symbol = :ticker_symbol", ticker_symbol: args.ticker_symbol)
    end
    Rails.logger.info "target stocks.length=#{stocks.length}"

    ticker_symbol_years = []
    stocks.each.with_index(1) do |stock, stock_index|
      Rails.logger.info "foreach stock: start: #{stock_index}/#{stocks.length}: ticker_symbol=#{stock.ticker_symbol}"

      if args.year == "all"
        years = Stock.get_years("stock_detail_#{stock.ticker_symbol}.html")
      else
        years = [args.year.to_i]
      end

      years.each do |year|
        ticker_symbol_years << { ticker_symbol: stock.ticker_symbol, year: year }
      end

      Rails.logger.info "ticker_symbol=#{stock.ticker_symbol}, years=#{years}"

      Rails.logger.info "foreach stock: end"
    end

    ticker_symbol_years.each.with_index(1) do |record, index|
      Rails.logger.info "import_stock_price_csv: start: #{index}/#{ticker_symbol_years.length}: ticker_symbol=#{record[:ticker_symbol]}, year=#{record[:year]}"
      stock_prices = StockPrice.get_stock_prices("stock_price_#{record[:ticker_symbol]}_#{record[:year]}.csv", record[:ticker_symbol])
      StockPrice.import(stock_prices)
      Rails.logger.info "import_stock_price_csv: end"
    end
  end

  task :download_nikkei_averages, [:year, :missing_only] => :environment do |task, args|
    missing_only = (args.missing_only == "true")
    Rails.logger.info "download_nikkei_averages: start: year=#{args.year}, missing_only=#{missing_only}"

    if args.year == "all"
      target_dates = (Date.new(1949, 5, 1) .. Date.today).select { |d| d.day == 1 }
    elsif args.year.to_i == Date.today.year
      target_dates = (Date.new(Date.today.year, 1, 1) .. Date.today).select { |d| d.day == 1 }
    else
      target_dates = (Date.new(args.year.to_i, 1, 1) .. Date.new(args.year.to_i, 12, 31)).select { |d| d.day == 1 }
    end

    target_dates.each.with_index(1) do |target_date, target_date_index|
      Rails.logger.info "download nikkei average: foreach date: #{target_date_index}/#{target_dates.length}: date=#{target_date}"
      NikkeiAverage.download_nikkei_average_html(target_date.year, target_date.month, missing_only)
    end
  end

  task :import_nikkei_averages, [:year] => :environment do |task, args|
    Rails.logger.info "import_nikkei_averages: start: year=#{args.year}"

    if args.year == "all"
      target_dates = (Date.new(1949, 5, 1) .. Date.today).select { |d| d.day == 1 }
    elsif args.year.to_i == Date.today.year
      target_dates = (Date.new(Date.today.year, 1, 1) .. Date.today).select { |d| d.day == 1 }
    else
      target_dates = (Date.new(args.year.to_i, 1, 1) .. Date.new(args.year.to_i, 12, 31)).select { |d| d.day == 1 }
    end

    target_dates.each.with_index(1) do |target_date, target_date_index|
      Rails.logger.info "import nikkei average: foreach date: #{target_date_index}/#{target_dates.length}: date=#{target_date}"
      nikkei_averages = NikkeiAverage.get_nikkei_averages("nikkei_average_#{target_date.year}_#{format("%02d", target_date.month)}.html")
      NikkeiAverage.import(nikkei_averages)
    end
  end

  task :download_topixes, [:year] => :environment do |task, args|
    Rails.logger.info "download_topixes: start: year=#{args.year}"

    if args.year == "all"
      date_from = Date.new(1980, 1, 1)
      date_to = Date.today  
    else
      date_from = Date.new(args.year.to_i, 1, 1)
      date_to = Date.new(args.year.to_i + 1, 1, 1)
    end

    Topix.download_topix_csv(date_from, date_to)
  end

  task :import_topixes, [:year] => :environment do |task, args|
    Rails.logger.info "import_topixes: start: year=#{args.year}"

    if args.year == "all"
      date_from = Date.new(1980, 1, 1)
      date_to = Date.today  
    else
      date_from = Date.new(args.year.to_i, 1, 1)
      date_to = Date.new(args.year.to_i + 1, 1, 1)
    end

    Rails.logger.info "import topix: start: date: from #{date_from.strftime('%Y%m%d')} to_#{date_to.strftime('%Y%m%d')}"
    topixes = Topix.get_topixes("topix_#{date_from.strftime('%Y%m%d')}_#{date_to.strftime('%Y%m%d')}.csv")
    topix_ids = Topix.import(topixes)
    Rails.logger.info "import topix: end: result=#{topix_ids.length}"
  end

  task :download_dow_jones_industrial_averages, [:year] => :environment do |task, args|
    Rails.logger.info "download_dow jones industrial averages: start: year=#{args.year}"

    if args.year == "all"
      date_from = Date.new(1987, 2, 1)
      date_to = Date.today  
    else
      date_from = Date.new(args.year.to_i, 1, 1)
      date_to = Date.new(args.year.to_i + 1, 1, 1)
    end

    DowJonesIndustrialAverage.download_djia_csv(date_from, date_to)
  end

  task :import_dow_jones_industrial_averages, [:year] => :environment do |task, args|
    Rails.logger.info "import dow jones industrial averages: start: year=#{args.year}"

    if args.year == "all"
      date_from = Date.new(1987, 2, 1)
      date_to = Date.today  
    else
      date_from = Date.new(args.year.to_i, 1, 1)
      date_to = Date.new(args.year.to_i + 1, 1, 1)
    end

    Rails.logger.info "import dow jones industrial averages: start: date: from #{date_from.strftime('%Y%m%d')} to_#{date_to.strftime('%Y%m%d')}"
    djias = DowJonesIndustrialAverage.get_djias("djia_#{date_from.strftime('%Y%m%d')}_#{date_to.strftime('%Y%m%d')}.csv")
    djia_ids = DowJonesIndustrialAverage.import(djias)
    Rails.logger.info "import dow jones industrial averages: end: result=#{djia_ids.length}"
  end

end
