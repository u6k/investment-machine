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
    data, page_links = result[:data], result[:page_links]
    Stock.put_index_page(data)
    Rails.logger.info "download_stocks: download_index_page: end: length=#{page_links.length}"

    task_failed = false
    page_links.each.with_index(1) do |page_link, index|
      Rails.logger.info "download_stocks: download_stock_list_page: #{index}/#{page_links.length}, page_link=#{page_link}"
      begin
        result = Stock.download_stock_list_page(page_link)
        Stock.put_stock_list_page(page_link, result[:data])
      rescue => e
        Rails.logger.error "#{e.class} (#{e.message}):\n#{e.backtrace.join("\n")}"
        task_failed = true
      end
    end

    Rails.logger.info "download_stocks: end"
    raise "failed" if task_failed
  end

  task :import_stocks, [] => :environment do |task, args|
    Rails.logger.info "import_stocks: start"

    bucket = Stock._get_s3_bucket

    Rails.logger.info "import_stocks: get_page_links: start"
    data = Stock.get_index_page
    page_links = Stock.parse_index_page(data)
    Rails.logger.info "import_stocks: get_page_links: end: length=#{page_links.length}"

    page_links.each.with_index(1) do |page_link, index|
      Rails.logger.info "import_stocks: import: start: #{index}/#{page_links.length}: page_link=#{page_link}"
      data = Stock.get_stock_list_page(page_link)
      stocks = Stock.parse_stock_list_page(data)
      Stock.import(stocks)
      Rails.logger.info "import_stocks: import: end: stocks.length=#{stocks.length}"
    end

    Rails.logger.info "import_stocks: end: Stock.all.length=#{Stock.all.length}"
  end

  task :download_stock_prices, [:ticker_symbol, :year, :missing_only] => :environment do |task, args|
    missing_only = (args.missing_only == "true")
    Rails.logger.info "download_stock_prices: start: ticker_symbol=#{args.ticker_symbol}, year=#{args.year}, missing_only=#{missing_only}"

    bucket = Stock._get_s3_bucket

    if args.ticker_symbol == "all"
      stocks = Stock.all
    else
      stocks = Stock.where("ticker_symbol = :ticker_symbol", ticker_symbol: args.ticker_symbol)
    end
    Rails.logger.info "download_stock_prices: stocks.length=#{stocks.length}"

    ticker_symbol_years = []
    stocks.each.with_index(1) do |stock, stock_index|
      Rails.logger.info "download_stock_prices: get_years: start: #{stock_index}/#{stocks.length}: ticker_symbol=#{stock.ticker_symbol}"

      if args.year == "all"
        result = Stock.download_stock_detail_page(stock.ticker_symbol, missing_only)
        if result == nil
          years = Stock.parse_stock_detail_page(Stock.get_stock_detail_page(stock.ticker_symbol))
        else
          Stock.put_stock_detail_page(stock.ticker_symbol, result[:data])
          years = result[:years]
        end
      else
        years = [args.year.to_i]
      end

      years.each do |year|
        ticker_symbol_years << { ticker_symbol: stock.ticker_symbol, year: year }
      end

      Rails.logger.info "download_stock_prices: get_years: end: #{stock_index}/#{stocks.length}: ticker_symbol=#{stock.ticker_symbol}, years=#{years}"
    end

    ticker_symbol_years.each.with_index(1) do |record, index|
      Rails.logger.info "download_stock_prices: csv: start: #{index}/#{ticker_symbol_years.length}: ticker_symbol=#{record[:ticker_symbol]}, year=#{record[:year]}"
      result = StockPrice.download_stock_price_csv(record[:ticker_symbol], record[:year], missing_only)
      if result != nil
        StockPrice.put_stock_price_csv(record[:ticker_symbol], record[:year], result[:data])
      end
    end
  end

  task :import_stock_prices, [:ticker_symbol, :year] => :environment do |task, args|
    Rails.logger.info "import_stock_prices: start: ticker_symbol=#{args.ticker_symbol}, year=#{args.year}"

    if args.ticker_symbol == "all"
      stocks = Stock.all
    else
      stocks = Stock.where("ticker_symbol = :ticker_symbol", ticker_symbol: args.ticker_symbol)
    end
    Rails.logger.info "import_stock_prices: stocks.length=#{stocks.length}"

    ticker_symbol_years = []
    stocks.each.with_index(1) do |stock, stock_index|
      Rails.logger.info "import_stock_prices: get_years: start: #{stock_index}/#{stocks.length}: ticker_symbol=#{stock.ticker_symbol}"

      if args.year == "all"
        years = Stock.parse_stock_detail_page(Stock.get_stock_detail_page(stock.ticker_symbol))
      else
        years = [args.year.to_i]
      end

      years.each do |year|
        ticker_symbol_years << { ticker_symbol: stock.ticker_symbol, year: year }
      end

      Rails.logger.info "import_stock_prices: get_years: end: ticker_symbol=#{stock.ticker_symbol}, years=#{years}"
    end

    ticker_symbol_years.each.with_index(1) do |record, index|
      Rails.logger.info "import_stock_prices: import: start: #{index}/#{ticker_symbol_years.length}: ticker_symbol=#{record[:ticker_symbol]}, year=#{record[:year]}"
      stock_prices = StockPrice.parse_stock_price_csv(StockPrice.get_stock_price_csv(record[:ticker_symbol], record[:year]), record[:ticker_symbol])
      StockPrice.import(stock_prices)
      Rails.logger.info "import_stock_prices: import: length=#{stock_prices.length}"
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
      Rails.logger.info "download nikkei average: download: #{target_date_index}/#{target_dates.length}: date=#{target_date}"
      result = NikkeiAverage.download_nikkei_average_html(target_date.year, target_date.month, missing_only)
      NikkeiAverage.put_nikkei_average_html(target_date.year, target_date.month, result[:data])
    end

    Rails.logger.info "download_nikkei_averages: end"
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
      Rails.logger.info "import nikkei average: import: start: #{target_date_index}/#{target_dates.length}: date=#{target_date}"
      data = NikkeiAverage.get_nikkei_average_html(target_date.year, target_date.month)
      nikkei_averages = NikkeiAverage.parse_nikkei_average_html(data)
      NikkeiAverage.import(nikkei_averages)
      Rails.logger.info "import nikkei average: import: end: #{nikkei_averages.length}"
    end

    Rails.logger.info "import_nikkei_averages: end"
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

    result = Topix.download_topix_csv(date_from, date_to)
    Topix.put_topix_csv(date_from, date_to, result[:data])

    Rails.logger.info "download_topixes: end"
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

    Rails.logger.info "import_topixes: import: start: date_from #{date_from.strftime('%Y%m%d')} to_#{date_to.strftime('%Y%m%d')}"
    data = Topix.get_topix_csv(date_from, date_to)
    topixes = Topix.parse_topix_csv(data)
    topix_ids = Topix.import(topixes)
    Rails.logger.info "import_topixes: import: end: result=#{topix_ids.length}"
  end

  task :download_dow_jones_industrial_averages, [:year] => :environment do |task, args|
    Rails.logger.info "download_dow_jones_industrial_averages: start: year=#{args.year}"

    if args.year == "all"
      date_from = Date.new(1987, 2, 1)
      date_to = Date.today  
    else
      date_from = Date.new(args.year.to_i, 1, 1)
      date_to = Date.new(args.year.to_i + 1, 1, 1)
    end

    result = DowJonesIndustrialAverage.download_djia_csv(date_from, date_to)
    DowJonesIndustrialAverage.put_djia_csv(date_from, date_to, result[:data])

    Rails.logger.info "download_dow_jones_industrial_averages: end"
  end

  task :import_dow_jones_industrial_averages, [:year] => :environment do |task, args|
    Rails.logger.info "import_dow_jones_industrial_averages: start: year=#{args.year}"

    if args.year == "all"
      date_from = Date.new(1987, 2, 1)
      date_to = Date.today  
    else
      date_from = Date.new(args.year.to_i, 1, 1)
      date_to = Date.new(args.year.to_i + 1, 1, 1)
    end

    Rails.logger.info "import_dow_jones_industrial_averages: import: start: date_from=#{date_from.strftime('%Y%m%d')}, date_to=#{date_to.strftime('%Y%m%d')}"
    data = DowJonesIndustrialAverage.get_djia_csv(date_from, date_to)
    djias = DowJonesIndustrialAverage.parse_djia_csv(data)
    djia_ids = DowJonesIndustrialAverage.import(djias)
    Rails.logger.info "import_dow_jones_industrial_averages: end: result=#{djia_ids.length}"
  end

  task :download_wertpapier_report_feeds, [:ticker_symbol] => :environment do |task, args|
    Rails.logger.info "download_wertpapier_report_feeds: start: ticker_symbol=#{args.ticker_symbol}"

    # search stocks
    Rails.logger.info "download_wertpapier_report_feeds: search stocks: start"

    if args.ticker_symbol == "all"
      ticker_symbols = Stock.all.map { |stock| stock.ticker_symbol }
    else
      ticker_symbols = [ args.ticker_symbol ]
    end

    Rails.logger.info "download_wertpapier_report_feeds: search stocks: end: length=#{ticker_symbols.length}"

    # download feed
    ticker_symbols.each.with_index(1) do |ticker_symbol, index|
      Rails.logger.info "download_wertpapier_report_feeds: download feed: #{index}/#{ticker_symbols.length}: ticker_symbol=#{ticker_symbol}"
      result = WertpapierReport.download_feed(ticker_symbol)
      WertpapierReport.put_feed(ticker_symbol, result[:data])
    end

    Rails.logger.info "download_wertpapier_report_feeds: end"
  end

  task :import_wertpapier_report_feeds, [:ticker_symbol] => :environment do |task, args|
    Rails.logger.info "import_wertpapier_report_feeds: start: ticker_symbol=#{args.ticker_symbol}"

    # search stocks
    Rails.logger.info "import_wertpapier_report_feeds: search stocks: start"

    if args.ticker_symbol == "all"
      ticker_symbols = Stock.all.map { |stock| stock.ticker_symbol }
    else
      ticker_symbols = [ args.ticker_symbol ]
    end

    Rails.logger.info "import_wertpapier_report_feeds: search stocks: end: length=#{ticker_symbols.length}"

    # get and import wertpapier report feeds
    ticker_symbols.each.with_index(1) do |ticker_symbol, index|
      Rails.logger.info "import_wertpapier_report_feeds: import: start: #{index}/#{ticker_symbols.length}: ticker_symbol=#{ticker_symbol}"
      data = WertpapierReport.get_feed(ticker_symbol)
      wertpapier_reports = WertpapierReport.parse_feed(ticker_symbol, data)
      wertpapier_report_ids = WertpapierReport.import_feed(wertpapier_reports)
      Rails.logger.info "import_wertpapier_report_feeds: import: end: result=#{wertpapier_report_ids.length}"
    end

    Rails.logger.info "import_wertpapier_report_feeds: end"
  end

  task :download_wertpapier_report_zips, [:ticker_symbol, :missing_only] => :environment do |task, args|
    Rails.logger.info "download_wertpapier_report_zips: start: ticker_symbol=#{args.ticker_symbol}, missing_only=#{args.missing_only}"

    missing_only = (args.missing_only == "true")

    # search stocks
    Rails.logger.info "download_wertpapier_report_zips: search stocks: start"

    if args.ticker_symbol == "all"
      ticker_symbols = Stock.all.map { |stock| stock.ticker_symbol }
    else
      ticker_symbols = [ args.ticker_symbol ]
    end

    Rails.logger.info "download_wertpapier_report_zips: search stocks: end: length=#{ticker_symbols.length}"

    # search wertpapier reports
    wertpapier_reports = []
    ticker_symbols.each.with_index(1) do |ticker_symbol, index|
      Rails.logger.info "download_wertpapier_report_zips: search wertpapier reports: #{index}/#{ticker_symbols.length}"
      WertpapierReport.where("ticker_symbol = :ticker_symbol", ticker_symbol: ticker_symbol).each do |wr|
        wertpapier_reports << wr
      end
    end

    # download zip
    wertpapier_reports.each.with_index(1) do |wertpapier_report, index|
      Rails.logger.info "download_wertpapier_report_zips: #{index}/#{wertpapier_reports.length}"
      result = WertpapierReport.download_wertpapier_zip(wertpapier_report.ticker_symbol, wertpapier_report.entry_id, missing_only)
      if result != nil
        WertpapierReport.put_wertpapier_zip(wertpapier_report.ticker_symbol, wertpapier_report.entry_id, result[:data])
      end
    end

    Rails.logger.info "download_wertpapier_report_zips: end"
  end

end
