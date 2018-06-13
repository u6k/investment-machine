require "open-uri"
require "nokogiri"
require "aws-sdk-s3"

namespace :crawl do
  desc "Crawler"

  task :download_stocks, [] => :environment do |task, args|
    Rails.logger.info "download_stocks: start"

    bucket = Stock._get_s3_bucket

    Rails.logger.info "download_stocks: download_index_page: start"
    result = Stock.download_index_page
    Stock.put_index_page(bucket, result[:data])

    page_links = result[:page_links]
    Rails.logger.info "download_stocks: download_index_page: end: length=#{page_links.length}"

    page_links.each.with_index(1) do |page_link, index|
      Rails.logger.info "download_stocks: download_stock_list_page: #{index}/#{page_links.length}, page_link=#{page_link}"
      result = Stock.download_stock_list_page(page_link)
      Stock.put_stock_list_page(bucket, page_link, result[:data])
    end

    Rails.logger.info "download_stocks: end"
  end

  task :import_stocks, [] => :environment do |task, args|
    Rails.logger.info "import_stocks: start"

    bucket = Stock._get_s3_bucket

    Rails.logger.info "import_stocks: get_page_links: start"
    data = bucket.object("stock_list_index.html").get.body.read
    page_links = Stock.get_page_links(data)
    Rails.logger.info "import_stocks: get_page_links: end: length=#{page_links.length}"

    page_links.each.with_index(1) do |page_link, index|
      Rails.logger.info "import_stocks: import: start: #{index}/#{page_links.length}: page_link=#{page_link}"
      data = bucket.object("stock_list_#{page_link}.html").get.body.read
      stocks = Stock.get_stocks(data)
      Stock.import(stocks)
      Rails.logger.info "import_stocks: import: end: stocks.length=#{stocks.length}"
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

  task :download_wertpapier_report_feeds, [:ticker_symbol] => :environment do |task, args|
    Rails.logger.info "download wertpapier_reports: start: ticker_symbol=#{args.ticker_symbol}"

    # search stocks
    Rails.logger.info "select stocks: start"

    if args.ticker_symbol == "all"
      ticker_symbols = Stock.all.map { |stock| stock.ticker_symbol }
    else
      ticker_symbols = [ args.ticker_symbol ]
    end

    Rails.logger.info "select stocks: end: length=#{ticker_symbols.length}"

    # download feed
    Rails.logger.info "download feed: start"

    ticker_symbols.each.with_index(1) do |ticker_symbol, index|
      WertpapierReport.download_feed(ticker_symbol)
      Rails.logger.info "download feed: #{index}/#{ticker_symbols.length}: ticker_symbol=#{ticker_symbol}"
    end

    Rails.logger.info "download feed: end"

    # download zip
  end

  task :import_wertpapier_report_feeds, [:ticker_symbol] => :environment do |task, args|
    Rails.logger.info "import_wertpapier_report_feeds: start: ticker_symbol=#{args.ticker_symbol}"

    # search stocks
    Rails.logger.info "select stocks: start"

    if args.ticker_symbol == "all"
      ticker_symbols = Stock.all.map { |stock| stock.ticker_symbol }
    else
      ticker_symbols = [ args.ticker_symbol ]
    end

    Rails.logger.info "select stocks: end: length=#{ticker_symbols.length}"

    # get and import wertpapier report feeds
    Rails.logger.info "import wertpapier report feed: start"

    ticker_symbols.each.with_index(1) do |ticker_symbol, index|
      wertpapier_reports = WertpapierReport.get_feed(ticker_symbol, "wertpapier_feed_#{ticker_symbol}.atom")
      WertpapierReport.import_feed(wertpapier_reports)
      Rails.logger.info "import wertpapier report feed: #{index}/#{ticker_symbols.length}: ticker_symbol=#{ticker_symbol}, result=#{wertpapier_reports.length}"
    end

    Rails.logger.info "import_wertpapier_report_feeds: end"
  end

  task :download_wertpapier_report_zips, [:ticker_symbol, :missing_only] => :environment do |task, args|
    Rails.logger.info "download_wertpapier_report_zips: start: ticker_symbol=#{args.ticker_symbol}, missing_only=#{args.missing_only}"

    missing_only = (args.missing_only == "true")

    # search stocks
    Rails.logger.info "select stocks: start"

    if args.ticker_symbol == "all"
      ticker_symbols = Stock.all.map { |stock| stock.ticker_symbol }
    else
      ticker_symbols = [ args.ticker_symbol ]
    end

    Rails.logger.info "select stocks: end: length=#{ticker_symbols.length}"

    # search wertpapier reports
    Rails.logger.info "select wertpapier reports: start"

    wertpapier_reports = []
    ticker_symbols.each.with_index(1) do |ticker_symbol, index|
      WertpapierReport.where("ticker_symbol = :ticker_symbol", ticker_symbol: ticker_symbol).each do |wr|
        wertpapier_reports << wr
      end
      Rails.logger.info "select wertpapier reports: #{index}/#{ticker_symbols.length}"
    end

    Rails.logger.info "select wertpapier reports: end: length=#{wertpapier_reports.length}"

    # download zip
    Rails.logger.info "download wertpapier report zip: start"

    wertpapier_reports.each.with_index(1) do |wertpapier_report, index|
      WertpapierReport.download_wertpapier_zip(wertpapier_report.ticker_symbol, wertpapier_report.entry_id, missing_only)
      Rails.logger.info "download wertpapier report zip: #{index}/#{wertpapier_reports.length}"
    end

    Rails.logger.info "download wertpapier report zip: end"
  end

end
