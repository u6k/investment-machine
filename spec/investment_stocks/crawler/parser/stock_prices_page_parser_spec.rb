require "timecop"
require "webmock/rspec"

RSpec.describe InvestmentStocks::Crawler::Parser::StockPricesPageParser do
  before do
    # Setup database
    InvestmentStocks::Crawler::Model::Company.delete_all
    InvestmentStocks::Crawler::Model::StockPrice.delete_all

    # Setup parser
    @downloader = Crawline::Downloader.new("investment-stocks-crawler/#{InvestmentStocks::Crawler::VERSION}")

    WebMock.enable!

    @url = "https://kabuoji3.com/stock/1301/"
    WebMock.stub_request(:get, @url).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_prices_page.1301.html").read)

    @parser = InvestmentStocks::Crawler::Parser::StockPricesPageParser.new(@url, @downloader.download_with_get(@url))

    @url_2018 = "https://kabuoji3.com/stock/1301/2018/"
    WebMock.stub_request(:get, @url_2018).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_prices_page.1301.2018.html").read)

    @parser_2018 = InvestmentStocks::Crawler::Parser::StockPricesPageParser.new(@url_2018, @downloader.download_with_get(@url_2018))

    @url_error = "https://kabuoji3.com/stock/1301/9999/"
    WebMock.stub_request(:get, @url_error).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_prices_page.error.html").read)

    @parser_error = InvestmentStocks::Crawler::Parser::StockPricesPageParser.new(@url_error, @downloader.download_with_get(@url_error))

    WebMock.disable!
  end

  describe "#redownload?" do
    context "last 300 days" do
      it "always redownload" do
        expect(@parser).to be_redownload
      end
    end

    context "2018s" do
      it "redownload if newer than 30 days" do
        Timecop.freeze(Time.local(2019, 1, 26, 23, 59, 59)) do
          expect(@parser_2018).to be_redownload
        end
      end
  
      it "do not redownload if over 30 days old" do
        Timecop.freeze(Time.local(2019, 1, 27, 0, 0, 0)) do
          expect(@parser_2018).not_to be_redownload
        end
      end
    end
  end

  describe "#related_links" do
    context "last 300 days" do
      it "is stock list pages, and stock price list pages" do
        expect(@parser.related_links).to contain_exactly(
          "https://kabuoji3.com/stock/1301/",
          "https://kabuoji3.com/stock/1301/2019/",
          "https://kabuoji3.com/stock/1301/2018/",
          "https://kabuoji3.com/stock/1301/2017/",
          "https://kabuoji3.com/stock/1301/2016/",
          "https://kabuoji3.com/stock/1301/2015/",
          "https://kabuoji3.com/stock/1301/2014/",
          "https://kabuoji3.com/stock/1301/2013/",
          "https://kabuoji3.com/stock/1301/2012/",
          "https://kabuoji3.com/stock/1301/2011/",
          "https://kabuoji3.com/stock/1301/2010/",
          "https://kabuoji3.com/stock/1301/2009/",
          "https://kabuoji3.com/stock/1301/2008/",
          "https://kabuoji3.com/stock/1301/2007/",
          "https://kabuoji3.com/stock/1301/2006/",
          "https://kabuoji3.com/stock/1301/2005/",
          "https://kabuoji3.com/stock/1301/2004/",
          "https://kabuoji3.com/stock/1301/2003/",
          "https://kabuoji3.com/stock/1301/2002/",
          "https://kabuoji3.com/stock/1301/2001/",
          "https://kabuoji3.com/stock/1301/2000/",
          "https://kabuoji3.com/stock/1301/1999/",
          "https://kabuoji3.com/stock/1301/1998/",
          "https://kabuoji3.com/stock/1301/1997/",
          "https://kabuoji3.com/stock/1301/1996/",
          "https://kabuoji3.com/stock/1301/1995/",
          "https://kabuoji3.com/stock/1301/1994/",
          "https://kabuoji3.com/stock/1301/1993/",
          "https://kabuoji3.com/stock/1301/1992/",
          "https://kabuoji3.com/stock/1301/1991/",
          "https://kabuoji3.com/stock/1301/1990/",
          "https://kabuoji3.com/stock/1301/1989/",
          "https://kabuoji3.com/stock/1301/1988/",
          "https://kabuoji3.com/stock/1301/1987/",
          "https://kabuoji3.com/stock/1301/1986/",
          "https://kabuoji3.com/stock/1301/1985/",
          "https://kabuoji3.com/stock/1301/1984/",
          "https://kabuoji3.com/stock/1301/1983/",
        )
      end
    end

    context "2018s" do
      it "is stock list pages, and stock price list pages" do
        expect(@parser_2018.related_links).to contain_exactly(
          "https://kabuoji3.com/stock/1301/",
          "https://kabuoji3.com/stock/1301/2019/",
          "https://kabuoji3.com/stock/1301/2018/",
          "https://kabuoji3.com/stock/1301/2017/",
          "https://kabuoji3.com/stock/1301/2016/",
          "https://kabuoji3.com/stock/1301/2015/",
          "https://kabuoji3.com/stock/1301/2014/",
          "https://kabuoji3.com/stock/1301/2013/",
          "https://kabuoji3.com/stock/1301/2012/",
          "https://kabuoji3.com/stock/1301/2011/",
          "https://kabuoji3.com/stock/1301/2010/",
          "https://kabuoji3.com/stock/1301/2009/",
          "https://kabuoji3.com/stock/1301/2008/",
          "https://kabuoji3.com/stock/1301/2007/",
          "https://kabuoji3.com/stock/1301/2006/",
          "https://kabuoji3.com/stock/1301/2005/",
          "https://kabuoji3.com/stock/1301/2004/",
          "https://kabuoji3.com/stock/1301/2003/",
          "https://kabuoji3.com/stock/1301/2002/",
          "https://kabuoji3.com/stock/1301/2001/",
          "https://kabuoji3.com/stock/1301/2000/",
          "https://kabuoji3.com/stock/1301/1999/",
          "https://kabuoji3.com/stock/1301/1998/",
          "https://kabuoji3.com/stock/1301/1997/",
          "https://kabuoji3.com/stock/1301/1996/",
          "https://kabuoji3.com/stock/1301/1995/",
          "https://kabuoji3.com/stock/1301/1994/",
          "https://kabuoji3.com/stock/1301/1993/",
          "https://kabuoji3.com/stock/1301/1992/",
          "https://kabuoji3.com/stock/1301/1991/",
          "https://kabuoji3.com/stock/1301/1990/",
          "https://kabuoji3.com/stock/1301/1989/",
          "https://kabuoji3.com/stock/1301/1988/",
          "https://kabuoji3.com/stock/1301/1987/",
          "https://kabuoji3.com/stock/1301/1986/",
          "https://kabuoji3.com/stock/1301/1985/",
          "https://kabuoji3.com/stock/1301/1984/",
          "https://kabuoji3.com/stock/1301/1983/",
        )
      end
    end
  end

  describe "#parse" do
    context "last 300 days" do
      it "saved company info only" do
        context = {}

        @parser.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::Company.all).to match_array([
          have_attributes(ticker_symbol: "1301",
                          name: "(株)極洋",
                          market: "東証1部")
        ])

        expect(InvestmentStocks::Crawler::Model::StockPrice.all).to be_empty
      end

      it "overwrite if exist data" do
        InvestmentStocks::Crawler::Model::Company.create(ticker_symbol: "1300", name: "test_1300", market: "test_market_1300")
        InvestmentStocks::Crawler::Model::Company.create(ticker_symbol: "1301", name: "test_1301", market: "test_market_1301")
        InvestmentStocks::Crawler::Model::Company.create(ticker_symbol: "1302", name: "test_1302", market: "test_market_1302")

        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2017,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2017, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2018,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2018, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2019,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2019, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)

        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2017,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2017, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2018,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2018, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2019,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2019, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)

        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2017,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2017, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2018,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2018, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2019,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2019, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)

        context = {}

        @parser.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::Company.all).to match_array([
          have_attributes(ticker_symbol: "1300", name: "test_1300", market: "test_market_1300"),
          have_attributes(ticker_symbol: "1301",
                          name: "(株)極洋",
                          market: "東証1部"),
          have_attributes(ticker_symbol: "1302", name: "test_1302", market: "test_market_1302"),
        ])

        expect(InvestmentStocks::Crawler::Model::StockPrice.all).to match_array([
          have_attributes(ticker_symbol: "1300", date: Time.local(2017,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2017, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2018,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2018, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2019,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2019, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1301", date: Time.local(2017,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2017, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2019, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1302", date: Time.local(2017,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2017, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2018,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2018, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2019,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2019, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
        ])
      end
    end

    context "2018s" do
      it "saved company info, and stock prices" do
        @parser_2018.parse({})

        expect(InvestmentStocks::Crawler::Model::Company.all).to match_array([
          have_attributes(ticker_symbol: "1301",
                          name: "(株)極洋",
                          market: "東証1部")
        ])

        expect(InvestmentStocks::Crawler::Model::StockPrice.all).to match_array([
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 4), open_price: 4270, high_price: 4335, low_price: 4220, close_price: 4320, volume: 61500, adjusted_close_price: 4320),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 5), open_price: 4330, high_price: 4360, low_price: 4285, close_price: 4340, volume: 55300, adjusted_close_price: 4340),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 9), open_price: 4340, high_price: 4360, low_price: 4325, close_price: 4340, volume: 26100, adjusted_close_price: 4340),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 10), open_price: 4340, high_price: 4460, low_price: 4340, close_price: 4430, volume: 91300, adjusted_close_price: 4430),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 11), open_price: 4430, high_price: 4430, low_price: 4340, close_price: 4350, volume: 48200, adjusted_close_price: 4350),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 12), open_price: 4345, high_price: 4345, low_price: 4265, close_price: 4270, volume: 42500, adjusted_close_price: 4270),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 15), open_price: 4280, high_price: 4285, low_price: 4255, close_price: 4260, volume: 31100, adjusted_close_price: 4260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 16), open_price: 4250, high_price: 4325, low_price: 4230, close_price: 4305, volume: 37300, adjusted_close_price: 4305),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 17), open_price: 4300, high_price: 4315, low_price: 4250, close_price: 4255, volume: 31200, adjusted_close_price: 4255),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 18), open_price: 4275, high_price: 4280, low_price: 4160, close_price: 4170, volume: 47300, adjusted_close_price: 4170),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 19), open_price: 4165, high_price: 4250, low_price: 4160, close_price: 4230, volume: 55000, adjusted_close_price: 4230),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 22), open_price: 4230, high_price: 4240, low_price: 4160, close_price: 4190, volume: 41000, adjusted_close_price: 4190),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 23), open_price: 4300, high_price: 4305, low_price: 4255, close_price: 4260, volume: 54000, adjusted_close_price: 4260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 24), open_price: 4265, high_price: 4290, low_price: 4250, close_price: 4260, volume: 32400, adjusted_close_price: 4260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 25), open_price: 4260, high_price: 4300, low_price: 4210, close_price: 4280, volume: 40900, adjusted_close_price: 4280),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 26), open_price: 4280, high_price: 4305, low_price: 4275, close_price: 4290, volume: 26400, adjusted_close_price: 4290),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 29), open_price: 4290, high_price: 4345, low_price: 4270, close_price: 4270, volume: 32600, adjusted_close_price: 4270),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 30), open_price: 4250, high_price: 4250, low_price: 4170, close_price: 4190, volume: 38400, adjusted_close_price: 4190),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 31), open_price: 4160, high_price: 4210, low_price: 4140, close_price: 4140, volume: 41700, adjusted_close_price: 4140),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 1), open_price: 4150, high_price: 4195, low_price: 4130, close_price: 4170, volume: 21400, adjusted_close_price: 4170),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 2), open_price: 4150, high_price: 4180, low_price: 4140, close_price: 4175, volume: 20700, adjusted_close_price: 4175),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 5), open_price: 4100, high_price: 4125, low_price: 4055, close_price: 4085, volume: 49200, adjusted_close_price: 4085),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 6), open_price: 3910, high_price: 3910, low_price: 3830, close_price: 3900, volume: 89200, adjusted_close_price: 3900),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 7), open_price: 3995, high_price: 4050, low_price: 3875, close_price: 3880, volume: 47600, adjusted_close_price: 3880),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 8), open_price: 3880, high_price: 3925, low_price: 3870, close_price: 3885, volume: 31800, adjusted_close_price: 3885),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 9), open_price: 3800, high_price: 3865, low_price: 3770, close_price: 3810, volume: 72200, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 13), open_price: 3850, high_price: 3860, low_price: 3680, close_price: 3695, volume: 81400, adjusted_close_price: 3695),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 14), open_price: 3700, high_price: 3735, low_price: 3645, close_price: 3700, volume: 49200, adjusted_close_price: 3700),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 15), open_price: 3705, high_price: 3730, low_price: 3675, close_price: 3715, volume: 48600, adjusted_close_price: 3715),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 16), open_price: 3740, high_price: 3835, low_price: 3740, close_price: 3820, volume: 47100, adjusted_close_price: 3820),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 19), open_price: 3850, high_price: 3890, low_price: 3845, close_price: 3880, volume: 24000, adjusted_close_price: 3880),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 20), open_price: 3920, high_price: 3920, low_price: 3870, close_price: 3895, volume: 27600, adjusted_close_price: 3895),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 21), open_price: 3920, high_price: 3945, low_price: 3875, close_price: 3915, volume: 27000, adjusted_close_price: 3915),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 22), open_price: 3925, high_price: 3925, low_price: 3825, close_price: 3870, volume: 28800, adjusted_close_price: 3870),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 23), open_price: 3875, high_price: 3930, low_price: 3875, close_price: 3930, volume: 22600, adjusted_close_price: 3930),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 26), open_price: 3950, high_price: 3955, low_price: 3905, close_price: 3915, volume: 30800, adjusted_close_price: 3915),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 27), open_price: 3915, high_price: 3920, low_price: 3850, close_price: 3855, volume: 44200, adjusted_close_price: 3855),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 28), open_price: 3845, high_price: 3885, low_price: 3835, close_price: 3835, volume: 51700, adjusted_close_price: 3835),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 1), open_price: 3825, high_price: 3825, low_price: 3765, close_price: 3770, volume: 39400, adjusted_close_price: 3770),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 2), open_price: 3745, high_price: 3755, low_price: 3700, close_price: 3740, volume: 31100, adjusted_close_price: 3740),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 5), open_price: 3770, high_price: 3815, low_price: 3740, close_price: 3760, volume: 30900, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 6), open_price: 3780, high_price: 3825, low_price: 3780, close_price: 3815, volume: 24300, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 7), open_price: 3815, high_price: 3860, low_price: 3795, close_price: 3820, volume: 22900, adjusted_close_price: 3820),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 8), open_price: 3865, high_price: 3875, low_price: 3830, close_price: 3865, volume: 29100, adjusted_close_price: 3865),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 9), open_price: 3895, high_price: 3920, low_price: 3845, close_price: 3875, volume: 41500, adjusted_close_price: 3875),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 12), open_price: 3920, high_price: 3920, low_price: 3870, close_price: 3905, volume: 31200, adjusted_close_price: 3905),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 13), open_price: 3895, high_price: 3925, low_price: 3885, close_price: 3925, volume: 25000, adjusted_close_price: 3925),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 14), open_price: 3905, high_price: 3920, low_price: 3890, close_price: 3900, volume: 20500, adjusted_close_price: 3900),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 15), open_price: 3890, high_price: 3895, low_price: 3840, close_price: 3885, volume: 25200, adjusted_close_price: 3885),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 16), open_price: 3890, high_price: 3895, low_price: 3860, close_price: 3895, volume: 43200, adjusted_close_price: 3895),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 19), open_price: 3890, high_price: 3895, low_price: 3830, close_price: 3845, volume: 35500, adjusted_close_price: 3845),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 20), open_price: 3830, high_price: 3865, low_price: 3785, close_price: 3865, volume: 29200, adjusted_close_price: 3865),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 22), open_price: 3855, high_price: 3885, low_price: 3850, close_price: 3880, volume: 28800, adjusted_close_price: 3880),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 23), open_price: 3830, high_price: 3840, low_price: 3800, close_price: 3815, volume: 37800, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 26), open_price: 3785, high_price: 3860, low_price: 3780, close_price: 3860, volume: 43900, adjusted_close_price: 3860),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 27), open_price: 3890, high_price: 3930, low_price: 3880, close_price: 3930, volume: 106900, adjusted_close_price: 3930),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 28), open_price: 3800, high_price: 3815, low_price: 3765, close_price: 3800, volume: 64000, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 29), open_price: 3820, high_price: 3830, low_price: 3785, close_price: 3820, volume: 26500, adjusted_close_price: 3820),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 30), open_price: 3840, high_price: 3840, low_price: 3785, close_price: 3800, volume: 23500, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 2), open_price: 3800, high_price: 3800, low_price: 3740, close_price: 3750, volume: 28000, adjusted_close_price: 3750),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 3), open_price: 3690, high_price: 3755, low_price: 3680, close_price: 3735, volume: 24500, adjusted_close_price: 3735),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 4), open_price: 3735, high_price: 3805, low_price: 3720, close_price: 3805, volume: 25900, adjusted_close_price: 3805),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 5), open_price: 3805, high_price: 3830, low_price: 3795, close_price: 3810, volume: 20600, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 6), open_price: 3840, high_price: 3840, low_price: 3790, close_price: 3790, volume: 18400, adjusted_close_price: 3790),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 9), open_price: 3765, high_price: 3850, low_price: 3760, close_price: 3830, volume: 28600, adjusted_close_price: 3830),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 10), open_price: 3830, high_price: 3870, low_price: 3805, close_price: 3830, volume: 27200, adjusted_close_price: 3830),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 11), open_price: 3810, high_price: 3815, low_price: 3745, close_price: 3755, volume: 27100, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 12), open_price: 3750, high_price: 3770, low_price: 3740, close_price: 3760, volume: 14500, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 13), open_price: 3770, high_price: 3785, low_price: 3740, close_price: 3760, volume: 12800, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 16), open_price: 3755, high_price: 3805, low_price: 3740, close_price: 3800, volume: 14700, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 17), open_price: 3800, high_price: 3815, low_price: 3755, close_price: 3755, volume: 12200, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 18), open_price: 3760, high_price: 3775, low_price: 3735, close_price: 3750, volume: 15000, adjusted_close_price: 3750),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 19), open_price: 3750, high_price: 3760, low_price: 3735, close_price: 3755, volume: 14300, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 20), open_price: 3775, high_price: 3775, low_price: 3745, close_price: 3755, volume: 12200, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 23), open_price: 3730, high_price: 3730, low_price: 3690, close_price: 3705, volume: 23100, adjusted_close_price: 3705),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 24), open_price: 3710, high_price: 3740, low_price: 3705, close_price: 3725, volume: 21500, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 25), open_price: 3705, high_price: 3740, low_price: 3705, close_price: 3725, volume: 11900, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 26), open_price: 3725, high_price: 3730, low_price: 3705, close_price: 3725, volume: 19600, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 27), open_price: 3725, high_price: 3775, low_price: 3715, close_price: 3775, volume: 29400, adjusted_close_price: 3775),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 1), open_price: 3770, high_price: 3785, low_price: 3755, close_price: 3785, volume: 14300, adjusted_close_price: 3785),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 2), open_price: 3785, high_price: 3800, low_price: 3765, close_price: 3800, volume: 12100, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 7), open_price: 3810, high_price: 3810, low_price: 3775, close_price: 3785, volume: 22900, adjusted_close_price: 3785),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 8), open_price: 3765, high_price: 3845, low_price: 3760, close_price: 3825, volume: 32000, adjusted_close_price: 3825),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 9), open_price: 3790, high_price: 3840, low_price: 3790, close_price: 3825, volume: 24500, adjusted_close_price: 3825),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 10), open_price: 3840, high_price: 3870, low_price: 3760, close_price: 3815, volume: 44400, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 11), open_price: 3775, high_price: 3810, low_price: 3770, close_price: 3805, volume: 44100, adjusted_close_price: 3805),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 14), open_price: 3800, high_price: 3845, low_price: 3795, close_price: 3810, volume: 34000, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 15), open_price: 3820, high_price: 3855, low_price: 3820, close_price: 3845, volume: 24600, adjusted_close_price: 3845),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 16), open_price: 3825, high_price: 3845, low_price: 3800, close_price: 3815, volume: 22300, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 17), open_price: 3810, high_price: 3830, low_price: 3790, close_price: 3830, volume: 14900, adjusted_close_price: 3830),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 18), open_price: 3850, high_price: 3850, low_price: 3805, close_price: 3825, volume: 26600, adjusted_close_price: 3825),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 21), open_price: 3825, high_price: 3830, low_price: 3785, close_price: 3795, volume: 14800, adjusted_close_price: 3795),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 22), open_price: 3785, high_price: 3785, low_price: 3735, close_price: 3745, volume: 16800, adjusted_close_price: 3745),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 23), open_price: 3745, high_price: 3760, low_price: 3725, close_price: 3745, volume: 19900, adjusted_close_price: 3745),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 24), open_price: 3730, high_price: 3765, low_price: 3715, close_price: 3735, volume: 18300, adjusted_close_price: 3735),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 25), open_price: 3735, high_price: 3755, low_price: 3715, close_price: 3715, volume: 22100, adjusted_close_price: 3715),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 28), open_price: 3745, high_price: 3745, low_price: 3710, close_price: 3735, volume: 17900, adjusted_close_price: 3735),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 29), open_price: 3735, high_price: 3780, low_price: 3725, close_price: 3775, volume: 17000, adjusted_close_price: 3775),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 30), open_price: 3730, high_price: 3850, low_price: 3710, close_price: 3835, volume: 49600, adjusted_close_price: 3835),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 31), open_price: 3835, high_price: 3845, low_price: 3775, close_price: 3780, volume: 38000, adjusted_close_price: 3780),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 1), open_price: 3795, high_price: 3795, low_price: 3745, close_price: 3755, volume: 16300, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 4), open_price: 3765, high_price: 3810, low_price: 3765, close_price: 3805, volume: 13500, adjusted_close_price: 3805),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 5), open_price: 3805, high_price: 3830, low_price: 3760, close_price: 3775, volume: 13600, adjusted_close_price: 3775),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 6), open_price: 3755, high_price: 3770, low_price: 3725, close_price: 3725, volume: 18000, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 7), open_price: 3725, high_price: 3750, low_price: 3685, close_price: 3750, volume: 33700, adjusted_close_price: 3750),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 8), open_price: 3715, high_price: 3765, low_price: 3705, close_price: 3755, volume: 25200, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 11), open_price: 3750, high_price: 3820, low_price: 3730, close_price: 3810, volume: 22000, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 12), open_price: 3810, high_price: 3820, low_price: 3790, close_price: 3790, volume: 9200, adjusted_close_price: 3790),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 13), open_price: 3785, high_price: 3800, low_price: 3785, close_price: 3785, volume: 19700, adjusted_close_price: 3785),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 14), open_price: 3780, high_price: 3800, low_price: 3775, close_price: 3780, volume: 11200, adjusted_close_price: 3780),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 15), open_price: 3780, high_price: 3785, low_price: 3755, close_price: 3760, volume: 8300, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 18), open_price: 3780, high_price: 3780, low_price: 3710, close_price: 3720, volume: 16700, adjusted_close_price: 3720),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 19), open_price: 3710, high_price: 3710, low_price: 3645, close_price: 3660, volume: 22100, adjusted_close_price: 3660),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 20), open_price: 3690, high_price: 3715, low_price: 3665, close_price: 3705, volume: 18800, adjusted_close_price: 3705),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 21), open_price: 3680, high_price: 3700, low_price: 3665, close_price: 3680, volume: 14700, adjusted_close_price: 3680),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 22), open_price: 3650, high_price: 3660, low_price: 3610, close_price: 3640, volume: 26400, adjusted_close_price: 3640),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 25), open_price: 3640, high_price: 3640, low_price: 3570, close_price: 3590, volume: 27200, adjusted_close_price: 3590),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 26), open_price: 3570, high_price: 3625, low_price: 3535, close_price: 3615, volume: 21800, adjusted_close_price: 3615),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 27), open_price: 3610, high_price: 3655, low_price: 3555, close_price: 3630, volume: 22200, adjusted_close_price: 3630),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 28), open_price: 3615, high_price: 3615, low_price: 3555, close_price: 3605, volume: 21800, adjusted_close_price: 3605),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 29), open_price: 3650, high_price: 3650, low_price: 3575, close_price: 3595, volume: 18200, adjusted_close_price: 3595),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 2), open_price: 3600, high_price: 3600, low_price: 3510, close_price: 3520, volume: 29200, adjusted_close_price: 3520),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 3), open_price: 3550, high_price: 3560, low_price: 3525, close_price: 3540, volume: 23000, adjusted_close_price: 3540),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 4), open_price: 3505, high_price: 3595, low_price: 3495, close_price: 3575, volume: 38400, adjusted_close_price: 3575),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 5), open_price: 3550, high_price: 3560, low_price: 3465, close_price: 3470, volume: 23300, adjusted_close_price: 3470),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 6), open_price: 3465, high_price: 3475, low_price: 3405, close_price: 3435, volume: 32700, adjusted_close_price: 3435),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 9), open_price: 3470, high_price: 3485, low_price: 3445, close_price: 3480, volume: 20500, adjusted_close_price: 3480),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 10), open_price: 3490, high_price: 3490, low_price: 3405, close_price: 3405, volume: 24600, adjusted_close_price: 3405),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 11), open_price: 3405, high_price: 3420, low_price: 3380, close_price: 3380, volume: 20300, adjusted_close_price: 3380),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 12), open_price: 3370, high_price: 3415, low_price: 3365, close_price: 3400, volume: 12500, adjusted_close_price: 3400),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 13), open_price: 3430, high_price: 3460, low_price: 3405, close_price: 3460, volume: 13500, adjusted_close_price: 3460),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 17), open_price: 3445, high_price: 3525, low_price: 3440, close_price: 3485, volume: 18900, adjusted_close_price: 3485),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 18), open_price: 3515, high_price: 3525, low_price: 3500, close_price: 3505, volume: 7800, adjusted_close_price: 3505),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 19), open_price: 3500, high_price: 3530, low_price: 3495, close_price: 3505, volume: 10100, adjusted_close_price: 3505),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 20), open_price: 3545, high_price: 3560, low_price: 3500, close_price: 3535, volume: 13600, adjusted_close_price: 3535),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 23), open_price: 3550, high_price: 3575, low_price: 3515, close_price: 3530, volume: 26200, adjusted_close_price: 3530),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 24), open_price: 3515, high_price: 3615, low_price: 3515, close_price: 3565, volume: 19500, adjusted_close_price: 3565),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 25), open_price: 3570, high_price: 3590, low_price: 3565, close_price: 3570, volume: 11500, adjusted_close_price: 3570),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 26), open_price: 3570, high_price: 3620, low_price: 3570, close_price: 3590, volume: 11500, adjusted_close_price: 3590),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 27), open_price: 3615, high_price: 3615, low_price: 3580, close_price: 3585, volume: 10500, adjusted_close_price: 3585),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 30), open_price: 3570, high_price: 3575, low_price: 3550, close_price: 3570, volume: 10300, adjusted_close_price: 3570),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 31), open_price: 3530, high_price: 3560, low_price: 3475, close_price: 3480, volume: 33600, adjusted_close_price: 3480),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 1), open_price: 3575, high_price: 3575, low_price: 3450, close_price: 3470, volume: 22800, adjusted_close_price: 3470),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 2), open_price: 3470, high_price: 3485, low_price: 3435, close_price: 3435, volume: 13500, adjusted_close_price: 3435),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 3), open_price: 3420, high_price: 3445, low_price: 3215, close_price: 3260, volume: 61700, adjusted_close_price: 3260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 6), open_price: 3215, high_price: 3300, low_price: 3215, close_price: 3265, volume: 22800, adjusted_close_price: 3265),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 7), open_price: 3305, high_price: 3410, low_price: 3270, close_price: 3405, volume: 33300, adjusted_close_price: 3405),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 8), open_price: 3370, high_price: 3395, low_price: 3305, close_price: 3315, volume: 24700, adjusted_close_price: 3315),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 9), open_price: 3300, high_price: 3310, low_price: 3275, close_price: 3300, volume: 15000, adjusted_close_price: 3300),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 10), open_price: 3325, high_price: 3325, low_price: 3275, close_price: 3290, volume: 20500, adjusted_close_price: 3290),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 13), open_price: 3290, high_price: 3305, low_price: 3225, close_price: 3240, volume: 29600, adjusted_close_price: 3240),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 14), open_price: 3270, high_price: 3320, low_price: 3265, close_price: 3295, volume: 12800, adjusted_close_price: 3295),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 15), open_price: 3295, high_price: 3315, low_price: 3255, close_price: 3275, volume: 8100, adjusted_close_price: 3275),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 16), open_price: 3270, high_price: 3270, low_price: 3210, close_price: 3255, volume: 17000, adjusted_close_price: 3255),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 17), open_price: 3240, high_price: 3275, low_price: 3235, close_price: 3270, volume: 11000, adjusted_close_price: 3270),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 20), open_price: 3290, high_price: 3290, low_price: 3250, close_price: 3255, volume: 13800, adjusted_close_price: 3255),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 21), open_price: 3230, high_price: 3265, low_price: 3220, close_price: 3245, volume: 15700, adjusted_close_price: 3245),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 22), open_price: 3245, high_price: 3295, low_price: 3245, close_price: 3290, volume: 12400, adjusted_close_price: 3290),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 23), open_price: 3280, high_price: 3280, low_price: 3250, close_price: 3250, volume: 10400, adjusted_close_price: 3250),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 24), open_price: 3250, high_price: 3265, low_price: 3250, close_price: 3260, volume: 6800, adjusted_close_price: 3260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 27), open_price: 3260, high_price: 3260, low_price: 3215, close_price: 3225, volume: 33200, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 28), open_price: 3240, high_price: 3260, low_price: 3225, close_price: 3225, volume: 17800, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 29), open_price: 3225, high_price: 3235, low_price: 3215, close_price: 3220, volume: 16700, adjusted_close_price: 3220),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 30), open_price: 3240, high_price: 3255, low_price: 3195, close_price: 3195, volume: 29900, adjusted_close_price: 3195),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 31), open_price: 3210, high_price: 3210, low_price: 3140, close_price: 3145, volume: 48400, adjusted_close_price: 3145),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 3), open_price: 3150, high_price: 3150, low_price: 3100, close_price: 3115, volume: 31700, adjusted_close_price: 3115),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 4), open_price: 3130, high_price: 3240, low_price: 3120, close_price: 3200, volume: 35700, adjusted_close_price: 3200),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 5), open_price: 3180, high_price: 3215, low_price: 3180, close_price: 3215, volume: 14300, adjusted_close_price: 3215),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 6), open_price: 3195, high_price: 3195, low_price: 3115, close_price: 3120, volume: 30000, adjusted_close_price: 3120),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 7), open_price: 3120, high_price: 3145, low_price: 3085, close_price: 3115, volume: 30900, adjusted_close_price: 3115),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 10), open_price: 3120, high_price: 3150, low_price: 3095, close_price: 3130, volume: 26100, adjusted_close_price: 3130),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 11), open_price: 3125, high_price: 3130, low_price: 3075, close_price: 3095, volume: 29000, adjusted_close_price: 3095),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 12), open_price: 3105, high_price: 3110, low_price: 3070, close_price: 3095, volume: 19600, adjusted_close_price: 3095),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 13), open_price: 3105, high_price: 3160, low_price: 3100, close_price: 3140, volume: 32100, adjusted_close_price: 3140),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 14), open_price: 3190, high_price: 3195, low_price: 3165, close_price: 3185, volume: 29500, adjusted_close_price: 3185),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 18), open_price: 3185, high_price: 3280, low_price: 3180, close_price: 3280, volume: 33700, adjusted_close_price: 3280),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 19), open_price: 3330, high_price: 3350, low_price: 3295, close_price: 3330, volume: 32700, adjusted_close_price: 3330),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 20), open_price: 3350, high_price: 3350, low_price: 3300, close_price: 3320, volume: 16700, adjusted_close_price: 3320),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 21), open_price: 3340, high_price: 3340, low_price: 3265, close_price: 3310, volume: 39400, adjusted_close_price: 3310),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 25), open_price: 3300, high_price: 3385, low_price: 3300, close_price: 3385, volume: 25600, adjusted_close_price: 3385),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 26), open_price: 3420, high_price: 3495, low_price: 3410, close_price: 3485, volume: 35000, adjusted_close_price: 3485),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 27), open_price: 3445, high_price: 3500, low_price: 3390, close_price: 3395, volume: 19500, adjusted_close_price: 3395),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 28), open_price: 3440, high_price: 3445, low_price: 3395, close_price: 3400, volume: 11800, adjusted_close_price: 3400),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 1), open_price: 3415, high_price: 3445, low_price: 3380, close_price: 3380, volume: 14000, adjusted_close_price: 3380),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 2), open_price: 3385, high_price: 3415, low_price: 3360, close_price: 3365, volume: 12800, adjusted_close_price: 3365),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 3), open_price: 3360, high_price: 3370, low_price: 3340, close_price: 3340, volume: 14900, adjusted_close_price: 3340),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 4), open_price: 3340, high_price: 3365, low_price: 3320, close_price: 3330, volume: 9300, adjusted_close_price: 3330),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 5), open_price: 3300, high_price: 3340, low_price: 3300, close_price: 3315, volume: 12600, adjusted_close_price: 3315),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 9), open_price: 3295, high_price: 3295, low_price: 3230, close_price: 3245, volume: 15000, adjusted_close_price: 3245),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 10), open_price: 3235, high_price: 3325, low_price: 3235, close_price: 3300, volume: 13600, adjusted_close_price: 3300),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 11), open_price: 3190, high_price: 3225, low_price: 3175, close_price: 3195, volume: 28100, adjusted_close_price: 3195),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 12), open_price: 3170, high_price: 3205, low_price: 3145, close_price: 3175, volume: 25800, adjusted_close_price: 3175),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 15), open_price: 3185, high_price: 3185, low_price: 3115, close_price: 3115, volume: 22700, adjusted_close_price: 3115),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 16), open_price: 3110, high_price: 3125, low_price: 3080, close_price: 3120, volume: 19600, adjusted_close_price: 3120),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 17), open_price: 3150, high_price: 3165, low_price: 3115, close_price: 3135, volume: 23300, adjusted_close_price: 3135),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 18), open_price: 3135, high_price: 3170, low_price: 3135, close_price: 3145, volume: 12200, adjusted_close_price: 3145),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 19), open_price: 3145, high_price: 3145, low_price: 3100, close_price: 3110, volume: 24000, adjusted_close_price: 3110),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 22), open_price: 3120, high_price: 3140, low_price: 3100, close_price: 3110, volume: 24400, adjusted_close_price: 3110),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 23), open_price: 3120, high_price: 3120, low_price: 3055, close_price: 3055, volume: 38100, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 24), open_price: 3065, high_price: 3155, low_price: 3060, close_price: 3145, volume: 23100, adjusted_close_price: 3145),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 25), open_price: 3085, high_price: 3085, low_price: 3025, close_price: 3030, volume: 39700, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 26), open_price: 3080, high_price: 3080, low_price: 3015, close_price: 3070, volume: 33100, adjusted_close_price: 3070),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 29), open_price: 3070, high_price: 3090, low_price: 2997, close_price: 2997, volume: 32700, adjusted_close_price: 2997),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 30), open_price: 2995, high_price: 3025, low_price: 2981, close_price: 3005, volume: 27400, adjusted_close_price: 3005),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 31), open_price: 3025, high_price: 3105, low_price: 3025, close_price: 3095, volume: 26000, adjusted_close_price: 3095),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 1), open_price: 3100, high_price: 3105, low_price: 3070, close_price: 3090, volume: 16000, adjusted_close_price: 3090),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 2), open_price: 3100, high_price: 3130, low_price: 3055, close_price: 3110, volume: 31900, adjusted_close_price: 3110),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 5), open_price: 3100, high_price: 3100, low_price: 3015, close_price: 3025, volume: 38500, adjusted_close_price: 3025),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 6), open_price: 3015, high_price: 3115, low_price: 3010, close_price: 3045, volume: 30700, adjusted_close_price: 3045),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 7), open_price: 3045, high_price: 3080, low_price: 3010, close_price: 3020, volume: 35000, adjusted_close_price: 3020),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 8), open_price: 3060, high_price: 3085, low_price: 3050, close_price: 3065, volume: 18300, adjusted_close_price: 3065),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 9), open_price: 3055, high_price: 3100, low_price: 3045, close_price: 3055, volume: 29300, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 12), open_price: 3065, high_price: 3175, low_price: 3065, close_price: 3160, volume: 39400, adjusted_close_price: 3160),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 13), open_price: 3090, high_price: 3100, low_price: 3030, close_price: 3040, volume: 35700, adjusted_close_price: 3040),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 14), open_price: 3050, high_price: 3060, low_price: 3000, close_price: 3010, volume: 51200, adjusted_close_price: 3010),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 15), open_price: 3005, high_price: 3025, low_price: 2995, close_price: 3015, volume: 33900, adjusted_close_price: 3015),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 16), open_price: 3025, high_price: 3025, low_price: 3005, close_price: 3010, volume: 36500, adjusted_close_price: 3010),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 19), open_price: 3010, high_price: 3035, low_price: 2983, close_price: 3030, volume: 51500, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 20), open_price: 3035, high_price: 3100, low_price: 3020, close_price: 3075, volume: 34300, adjusted_close_price: 3075),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 21), open_price: 2989, high_price: 3050, low_price: 2987, close_price: 3040, volume: 21800, adjusted_close_price: 3040),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 22), open_price: 3035, high_price: 3070, low_price: 3010, close_price: 3065, volume: 21200, adjusted_close_price: 3065),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 26), open_price: 3060, high_price: 3105, low_price: 3055, close_price: 3100, volume: 30300, adjusted_close_price: 3100),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 27), open_price: 3110, high_price: 3165, low_price: 3110, close_price: 3150, volume: 23900, adjusted_close_price: 3150),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 28), open_price: 3165, high_price: 3170, low_price: 3130, close_price: 3155, volume: 16400, adjusted_close_price: 3155),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 29), open_price: 3185, high_price: 3250, low_price: 3185, close_price: 3215, volume: 36100, adjusted_close_price: 3215),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 30), open_price: 3245, high_price: 3245, low_price: 3195, close_price: 3225, volume: 25700, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 3), open_price: 3225, high_price: 3335, low_price: 3225, close_price: 3320, volume: 43300, adjusted_close_price: 3320),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 4), open_price: 3320, high_price: 3320, low_price: 3250, close_price: 3250, volume: 30600, adjusted_close_price: 3250),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 5), open_price: 3190, high_price: 3240, low_price: 3165, close_price: 3235, volume: 20800, adjusted_close_price: 3235),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 6), open_price: 3195, high_price: 3200, low_price: 3170, close_price: 3180, volume: 19800, adjusted_close_price: 3180),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 7), open_price: 3230, high_price: 3235, low_price: 3165, close_price: 3225, volume: 20700, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 10), open_price: 3185, high_price: 3185, low_price: 3105, close_price: 3105, volume: 20500, adjusted_close_price: 3105),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 11), open_price: 3110, high_price: 3115, low_price: 3030, close_price: 3030, volume: 21400, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 12), open_price: 3035, high_price: 3080, low_price: 3035, close_price: 3055, volume: 13400, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 13), open_price: 3080, high_price: 3090, low_price: 3055, close_price: 3085, volume: 21400, adjusted_close_price: 3085),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 14), open_price: 3085, high_price: 3110, low_price: 3050, close_price: 3055, volume: 21400, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 17), open_price: 3035, high_price: 3040, low_price: 3020, close_price: 3030, volume: 14400, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 18), open_price: 3005, high_price: 3010, low_price: 2975, close_price: 2975, volume: 32400, adjusted_close_price: 2975),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 19), open_price: 2972, high_price: 2986, low_price: 2943, close_price: 2963, volume: 19800, adjusted_close_price: 2963),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 20), open_price: 2940, high_price: 2950, low_price: 2853, close_price: 2872, volume: 33400, adjusted_close_price: 2872),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 21), open_price: 2852, high_price: 2852, low_price: 2741, close_price: 2745, volume: 55600, adjusted_close_price: 2745),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 25), open_price: 2624, high_price: 2650, low_price: 2581, close_price: 2607, volume: 54900, adjusted_close_price: 2607),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 26), open_price: 2630, high_price: 2753, low_price: 2630, close_price: 2699, volume: 30400, adjusted_close_price: 2699),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 27), open_price: 2820, high_price: 2893, low_price: 2784, close_price: 2874, volume: 33300, adjusted_close_price: 2874),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 28), open_price: 2874, high_price: 2908, low_price: 2840, close_price: 2882, volume: 24400, adjusted_close_price: 2882),
        ])
      end

      it "overwrite if exist data" do
        InvestmentStocks::Crawler::Model::Company.create(ticker_symbol: "1300", name: "test_1300", market: "test_market_1300")
        InvestmentStocks::Crawler::Model::Company.create(ticker_symbol: "1301", name: "test_1301", market: "test_market_1301")
        InvestmentStocks::Crawler::Model::Company.create(ticker_symbol: "1302", name: "test_1302", market: "test_market_1302")

        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2017,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2017, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2018,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2018, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2019,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1300", date: Time.new(2019, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300)

        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2017,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2017, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2018,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2018, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2019,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1301", date: Time.new(2019, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301)

        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2017,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2017, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2018,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2018, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2019,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)
        InvestmentStocks::Crawler::Model::StockPrice.create(ticker_symbol: "1302", date: Time.new(2019, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302)

        context = {}

        @parser_2018.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::Company.all).to match_array([
          have_attributes(ticker_symbol: "1300", name: "test_1300", market: "test_market_1300"),
          have_attributes(ticker_symbol: "1301",
                          name: "(株)極洋",
                          market: "東証1部"),
          have_attributes(ticker_symbol: "1302", name: "test_1302", market: "test_market_1302"),
        ])

        expect(InvestmentStocks::Crawler::Model::StockPrice.all).to match_array([
          have_attributes(ticker_symbol: "1300", date: Time.local(2017,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2017, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2018,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2018, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2019,  1,  1), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1300", date: Time.local(2019, 12, 31), open_price: 1300, high_price: 1300, low_price: 1300, close_price: 1300, volume: 1300, adjusted_close_price: 1300),
          have_attributes(ticker_symbol: "1301", date: Time.local(2017,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2017, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1,  1), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1301", date: Time.local(2019, 12, 31), open_price: 1301, high_price: 1301, low_price: 1301, close_price: 1301, volume: 1301, adjusted_close_price: 1301),
          have_attributes(ticker_symbol: "1302", date: Time.local(2017,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2017, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2018,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2018, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2019,  1,  1), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),
          have_attributes(ticker_symbol: "1302", date: Time.local(2019, 12, 31), open_price: 1302, high_price: 1302, low_price: 1302, close_price: 1302, volume: 1302, adjusted_close_price: 1302),

          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 4), open_price: 4270, high_price: 4335, low_price: 4220, close_price: 4320, volume: 61500, adjusted_close_price: 4320),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 5), open_price: 4330, high_price: 4360, low_price: 4285, close_price: 4340, volume: 55300, adjusted_close_price: 4340),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 9), open_price: 4340, high_price: 4360, low_price: 4325, close_price: 4340, volume: 26100, adjusted_close_price: 4340),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 10), open_price: 4340, high_price: 4460, low_price: 4340, close_price: 4430, volume: 91300, adjusted_close_price: 4430),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 11), open_price: 4430, high_price: 4430, low_price: 4340, close_price: 4350, volume: 48200, adjusted_close_price: 4350),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 12), open_price: 4345, high_price: 4345, low_price: 4265, close_price: 4270, volume: 42500, adjusted_close_price: 4270),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 15), open_price: 4280, high_price: 4285, low_price: 4255, close_price: 4260, volume: 31100, adjusted_close_price: 4260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 16), open_price: 4250, high_price: 4325, low_price: 4230, close_price: 4305, volume: 37300, adjusted_close_price: 4305),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 17), open_price: 4300, high_price: 4315, low_price: 4250, close_price: 4255, volume: 31200, adjusted_close_price: 4255),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 18), open_price: 4275, high_price: 4280, low_price: 4160, close_price: 4170, volume: 47300, adjusted_close_price: 4170),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 19), open_price: 4165, high_price: 4250, low_price: 4160, close_price: 4230, volume: 55000, adjusted_close_price: 4230),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 22), open_price: 4230, high_price: 4240, low_price: 4160, close_price: 4190, volume: 41000, adjusted_close_price: 4190),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 23), open_price: 4300, high_price: 4305, low_price: 4255, close_price: 4260, volume: 54000, adjusted_close_price: 4260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 24), open_price: 4265, high_price: 4290, low_price: 4250, close_price: 4260, volume: 32400, adjusted_close_price: 4260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 25), open_price: 4260, high_price: 4300, low_price: 4210, close_price: 4280, volume: 40900, adjusted_close_price: 4280),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 26), open_price: 4280, high_price: 4305, low_price: 4275, close_price: 4290, volume: 26400, adjusted_close_price: 4290),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 29), open_price: 4290, high_price: 4345, low_price: 4270, close_price: 4270, volume: 32600, adjusted_close_price: 4270),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 30), open_price: 4250, high_price: 4250, low_price: 4170, close_price: 4190, volume: 38400, adjusted_close_price: 4190),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 1, 31), open_price: 4160, high_price: 4210, low_price: 4140, close_price: 4140, volume: 41700, adjusted_close_price: 4140),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 1), open_price: 4150, high_price: 4195, low_price: 4130, close_price: 4170, volume: 21400, adjusted_close_price: 4170),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 2), open_price: 4150, high_price: 4180, low_price: 4140, close_price: 4175, volume: 20700, adjusted_close_price: 4175),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 5), open_price: 4100, high_price: 4125, low_price: 4055, close_price: 4085, volume: 49200, adjusted_close_price: 4085),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 6), open_price: 3910, high_price: 3910, low_price: 3830, close_price: 3900, volume: 89200, adjusted_close_price: 3900),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 7), open_price: 3995, high_price: 4050, low_price: 3875, close_price: 3880, volume: 47600, adjusted_close_price: 3880),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 8), open_price: 3880, high_price: 3925, low_price: 3870, close_price: 3885, volume: 31800, adjusted_close_price: 3885),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 9), open_price: 3800, high_price: 3865, low_price: 3770, close_price: 3810, volume: 72200, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 13), open_price: 3850, high_price: 3860, low_price: 3680, close_price: 3695, volume: 81400, adjusted_close_price: 3695),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 14), open_price: 3700, high_price: 3735, low_price: 3645, close_price: 3700, volume: 49200, adjusted_close_price: 3700),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 15), open_price: 3705, high_price: 3730, low_price: 3675, close_price: 3715, volume: 48600, adjusted_close_price: 3715),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 16), open_price: 3740, high_price: 3835, low_price: 3740, close_price: 3820, volume: 47100, adjusted_close_price: 3820),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 19), open_price: 3850, high_price: 3890, low_price: 3845, close_price: 3880, volume: 24000, adjusted_close_price: 3880),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 20), open_price: 3920, high_price: 3920, low_price: 3870, close_price: 3895, volume: 27600, adjusted_close_price: 3895),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 21), open_price: 3920, high_price: 3945, low_price: 3875, close_price: 3915, volume: 27000, adjusted_close_price: 3915),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 22), open_price: 3925, high_price: 3925, low_price: 3825, close_price: 3870, volume: 28800, adjusted_close_price: 3870),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 23), open_price: 3875, high_price: 3930, low_price: 3875, close_price: 3930, volume: 22600, adjusted_close_price: 3930),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 26), open_price: 3950, high_price: 3955, low_price: 3905, close_price: 3915, volume: 30800, adjusted_close_price: 3915),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 27), open_price: 3915, high_price: 3920, low_price: 3850, close_price: 3855, volume: 44200, adjusted_close_price: 3855),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 2, 28), open_price: 3845, high_price: 3885, low_price: 3835, close_price: 3835, volume: 51700, adjusted_close_price: 3835),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 1), open_price: 3825, high_price: 3825, low_price: 3765, close_price: 3770, volume: 39400, adjusted_close_price: 3770),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 2), open_price: 3745, high_price: 3755, low_price: 3700, close_price: 3740, volume: 31100, adjusted_close_price: 3740),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 5), open_price: 3770, high_price: 3815, low_price: 3740, close_price: 3760, volume: 30900, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 6), open_price: 3780, high_price: 3825, low_price: 3780, close_price: 3815, volume: 24300, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 7), open_price: 3815, high_price: 3860, low_price: 3795, close_price: 3820, volume: 22900, adjusted_close_price: 3820),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 8), open_price: 3865, high_price: 3875, low_price: 3830, close_price: 3865, volume: 29100, adjusted_close_price: 3865),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 9), open_price: 3895, high_price: 3920, low_price: 3845, close_price: 3875, volume: 41500, adjusted_close_price: 3875),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 12), open_price: 3920, high_price: 3920, low_price: 3870, close_price: 3905, volume: 31200, adjusted_close_price: 3905),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 13), open_price: 3895, high_price: 3925, low_price: 3885, close_price: 3925, volume: 25000, adjusted_close_price: 3925),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 14), open_price: 3905, high_price: 3920, low_price: 3890, close_price: 3900, volume: 20500, adjusted_close_price: 3900),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 15), open_price: 3890, high_price: 3895, low_price: 3840, close_price: 3885, volume: 25200, adjusted_close_price: 3885),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 16), open_price: 3890, high_price: 3895, low_price: 3860, close_price: 3895, volume: 43200, adjusted_close_price: 3895),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 19), open_price: 3890, high_price: 3895, low_price: 3830, close_price: 3845, volume: 35500, adjusted_close_price: 3845),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 20), open_price: 3830, high_price: 3865, low_price: 3785, close_price: 3865, volume: 29200, adjusted_close_price: 3865),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 22), open_price: 3855, high_price: 3885, low_price: 3850, close_price: 3880, volume: 28800, adjusted_close_price: 3880),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 23), open_price: 3830, high_price: 3840, low_price: 3800, close_price: 3815, volume: 37800, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 26), open_price: 3785, high_price: 3860, low_price: 3780, close_price: 3860, volume: 43900, adjusted_close_price: 3860),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 27), open_price: 3890, high_price: 3930, low_price: 3880, close_price: 3930, volume: 106900, adjusted_close_price: 3930),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 28), open_price: 3800, high_price: 3815, low_price: 3765, close_price: 3800, volume: 64000, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 29), open_price: 3820, high_price: 3830, low_price: 3785, close_price: 3820, volume: 26500, adjusted_close_price: 3820),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 3, 30), open_price: 3840, high_price: 3840, low_price: 3785, close_price: 3800, volume: 23500, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 2), open_price: 3800, high_price: 3800, low_price: 3740, close_price: 3750, volume: 28000, adjusted_close_price: 3750),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 3), open_price: 3690, high_price: 3755, low_price: 3680, close_price: 3735, volume: 24500, adjusted_close_price: 3735),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 4), open_price: 3735, high_price: 3805, low_price: 3720, close_price: 3805, volume: 25900, adjusted_close_price: 3805),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 5), open_price: 3805, high_price: 3830, low_price: 3795, close_price: 3810, volume: 20600, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 6), open_price: 3840, high_price: 3840, low_price: 3790, close_price: 3790, volume: 18400, adjusted_close_price: 3790),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 9), open_price: 3765, high_price: 3850, low_price: 3760, close_price: 3830, volume: 28600, adjusted_close_price: 3830),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 10), open_price: 3830, high_price: 3870, low_price: 3805, close_price: 3830, volume: 27200, adjusted_close_price: 3830),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 11), open_price: 3810, high_price: 3815, low_price: 3745, close_price: 3755, volume: 27100, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 12), open_price: 3750, high_price: 3770, low_price: 3740, close_price: 3760, volume: 14500, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 13), open_price: 3770, high_price: 3785, low_price: 3740, close_price: 3760, volume: 12800, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 16), open_price: 3755, high_price: 3805, low_price: 3740, close_price: 3800, volume: 14700, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 17), open_price: 3800, high_price: 3815, low_price: 3755, close_price: 3755, volume: 12200, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 18), open_price: 3760, high_price: 3775, low_price: 3735, close_price: 3750, volume: 15000, adjusted_close_price: 3750),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 19), open_price: 3750, high_price: 3760, low_price: 3735, close_price: 3755, volume: 14300, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 20), open_price: 3775, high_price: 3775, low_price: 3745, close_price: 3755, volume: 12200, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 23), open_price: 3730, high_price: 3730, low_price: 3690, close_price: 3705, volume: 23100, adjusted_close_price: 3705),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 24), open_price: 3710, high_price: 3740, low_price: 3705, close_price: 3725, volume: 21500, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 25), open_price: 3705, high_price: 3740, low_price: 3705, close_price: 3725, volume: 11900, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 26), open_price: 3725, high_price: 3730, low_price: 3705, close_price: 3725, volume: 19600, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 4, 27), open_price: 3725, high_price: 3775, low_price: 3715, close_price: 3775, volume: 29400, adjusted_close_price: 3775),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 1), open_price: 3770, high_price: 3785, low_price: 3755, close_price: 3785, volume: 14300, adjusted_close_price: 3785),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 2), open_price: 3785, high_price: 3800, low_price: 3765, close_price: 3800, volume: 12100, adjusted_close_price: 3800),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 7), open_price: 3810, high_price: 3810, low_price: 3775, close_price: 3785, volume: 22900, adjusted_close_price: 3785),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 8), open_price: 3765, high_price: 3845, low_price: 3760, close_price: 3825, volume: 32000, adjusted_close_price: 3825),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 9), open_price: 3790, high_price: 3840, low_price: 3790, close_price: 3825, volume: 24500, adjusted_close_price: 3825),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 10), open_price: 3840, high_price: 3870, low_price: 3760, close_price: 3815, volume: 44400, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 11), open_price: 3775, high_price: 3810, low_price: 3770, close_price: 3805, volume: 44100, adjusted_close_price: 3805),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 14), open_price: 3800, high_price: 3845, low_price: 3795, close_price: 3810, volume: 34000, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 15), open_price: 3820, high_price: 3855, low_price: 3820, close_price: 3845, volume: 24600, adjusted_close_price: 3845),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 16), open_price: 3825, high_price: 3845, low_price: 3800, close_price: 3815, volume: 22300, adjusted_close_price: 3815),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 17), open_price: 3810, high_price: 3830, low_price: 3790, close_price: 3830, volume: 14900, adjusted_close_price: 3830),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 18), open_price: 3850, high_price: 3850, low_price: 3805, close_price: 3825, volume: 26600, adjusted_close_price: 3825),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 21), open_price: 3825, high_price: 3830, low_price: 3785, close_price: 3795, volume: 14800, adjusted_close_price: 3795),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 22), open_price: 3785, high_price: 3785, low_price: 3735, close_price: 3745, volume: 16800, adjusted_close_price: 3745),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 23), open_price: 3745, high_price: 3760, low_price: 3725, close_price: 3745, volume: 19900, adjusted_close_price: 3745),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 24), open_price: 3730, high_price: 3765, low_price: 3715, close_price: 3735, volume: 18300, adjusted_close_price: 3735),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 25), open_price: 3735, high_price: 3755, low_price: 3715, close_price: 3715, volume: 22100, adjusted_close_price: 3715),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 28), open_price: 3745, high_price: 3745, low_price: 3710, close_price: 3735, volume: 17900, adjusted_close_price: 3735),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 29), open_price: 3735, high_price: 3780, low_price: 3725, close_price: 3775, volume: 17000, adjusted_close_price: 3775),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 30), open_price: 3730, high_price: 3850, low_price: 3710, close_price: 3835, volume: 49600, adjusted_close_price: 3835),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 5, 31), open_price: 3835, high_price: 3845, low_price: 3775, close_price: 3780, volume: 38000, adjusted_close_price: 3780),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 1), open_price: 3795, high_price: 3795, low_price: 3745, close_price: 3755, volume: 16300, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 4), open_price: 3765, high_price: 3810, low_price: 3765, close_price: 3805, volume: 13500, adjusted_close_price: 3805),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 5), open_price: 3805, high_price: 3830, low_price: 3760, close_price: 3775, volume: 13600, adjusted_close_price: 3775),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 6), open_price: 3755, high_price: 3770, low_price: 3725, close_price: 3725, volume: 18000, adjusted_close_price: 3725),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 7), open_price: 3725, high_price: 3750, low_price: 3685, close_price: 3750, volume: 33700, adjusted_close_price: 3750),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 8), open_price: 3715, high_price: 3765, low_price: 3705, close_price: 3755, volume: 25200, adjusted_close_price: 3755),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 11), open_price: 3750, high_price: 3820, low_price: 3730, close_price: 3810, volume: 22000, adjusted_close_price: 3810),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 12), open_price: 3810, high_price: 3820, low_price: 3790, close_price: 3790, volume: 9200, adjusted_close_price: 3790),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 13), open_price: 3785, high_price: 3800, low_price: 3785, close_price: 3785, volume: 19700, adjusted_close_price: 3785),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 14), open_price: 3780, high_price: 3800, low_price: 3775, close_price: 3780, volume: 11200, adjusted_close_price: 3780),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 15), open_price: 3780, high_price: 3785, low_price: 3755, close_price: 3760, volume: 8300, adjusted_close_price: 3760),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 18), open_price: 3780, high_price: 3780, low_price: 3710, close_price: 3720, volume: 16700, adjusted_close_price: 3720),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 19), open_price: 3710, high_price: 3710, low_price: 3645, close_price: 3660, volume: 22100, adjusted_close_price: 3660),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 20), open_price: 3690, high_price: 3715, low_price: 3665, close_price: 3705, volume: 18800, adjusted_close_price: 3705),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 21), open_price: 3680, high_price: 3700, low_price: 3665, close_price: 3680, volume: 14700, adjusted_close_price: 3680),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 22), open_price: 3650, high_price: 3660, low_price: 3610, close_price: 3640, volume: 26400, adjusted_close_price: 3640),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 25), open_price: 3640, high_price: 3640, low_price: 3570, close_price: 3590, volume: 27200, adjusted_close_price: 3590),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 26), open_price: 3570, high_price: 3625, low_price: 3535, close_price: 3615, volume: 21800, adjusted_close_price: 3615),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 27), open_price: 3610, high_price: 3655, low_price: 3555, close_price: 3630, volume: 22200, adjusted_close_price: 3630),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 28), open_price: 3615, high_price: 3615, low_price: 3555, close_price: 3605, volume: 21800, adjusted_close_price: 3605),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 6, 29), open_price: 3650, high_price: 3650, low_price: 3575, close_price: 3595, volume: 18200, adjusted_close_price: 3595),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 2), open_price: 3600, high_price: 3600, low_price: 3510, close_price: 3520, volume: 29200, adjusted_close_price: 3520),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 3), open_price: 3550, high_price: 3560, low_price: 3525, close_price: 3540, volume: 23000, adjusted_close_price: 3540),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 4), open_price: 3505, high_price: 3595, low_price: 3495, close_price: 3575, volume: 38400, adjusted_close_price: 3575),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 5), open_price: 3550, high_price: 3560, low_price: 3465, close_price: 3470, volume: 23300, adjusted_close_price: 3470),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 6), open_price: 3465, high_price: 3475, low_price: 3405, close_price: 3435, volume: 32700, adjusted_close_price: 3435),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 9), open_price: 3470, high_price: 3485, low_price: 3445, close_price: 3480, volume: 20500, adjusted_close_price: 3480),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 10), open_price: 3490, high_price: 3490, low_price: 3405, close_price: 3405, volume: 24600, adjusted_close_price: 3405),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 11), open_price: 3405, high_price: 3420, low_price: 3380, close_price: 3380, volume: 20300, adjusted_close_price: 3380),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 12), open_price: 3370, high_price: 3415, low_price: 3365, close_price: 3400, volume: 12500, adjusted_close_price: 3400),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 13), open_price: 3430, high_price: 3460, low_price: 3405, close_price: 3460, volume: 13500, adjusted_close_price: 3460),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 17), open_price: 3445, high_price: 3525, low_price: 3440, close_price: 3485, volume: 18900, adjusted_close_price: 3485),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 18), open_price: 3515, high_price: 3525, low_price: 3500, close_price: 3505, volume: 7800, adjusted_close_price: 3505),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 19), open_price: 3500, high_price: 3530, low_price: 3495, close_price: 3505, volume: 10100, adjusted_close_price: 3505),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 20), open_price: 3545, high_price: 3560, low_price: 3500, close_price: 3535, volume: 13600, adjusted_close_price: 3535),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 23), open_price: 3550, high_price: 3575, low_price: 3515, close_price: 3530, volume: 26200, adjusted_close_price: 3530),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 24), open_price: 3515, high_price: 3615, low_price: 3515, close_price: 3565, volume: 19500, adjusted_close_price: 3565),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 25), open_price: 3570, high_price: 3590, low_price: 3565, close_price: 3570, volume: 11500, adjusted_close_price: 3570),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 26), open_price: 3570, high_price: 3620, low_price: 3570, close_price: 3590, volume: 11500, adjusted_close_price: 3590),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 27), open_price: 3615, high_price: 3615, low_price: 3580, close_price: 3585, volume: 10500, adjusted_close_price: 3585),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 30), open_price: 3570, high_price: 3575, low_price: 3550, close_price: 3570, volume: 10300, adjusted_close_price: 3570),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 7, 31), open_price: 3530, high_price: 3560, low_price: 3475, close_price: 3480, volume: 33600, adjusted_close_price: 3480),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 1), open_price: 3575, high_price: 3575, low_price: 3450, close_price: 3470, volume: 22800, adjusted_close_price: 3470),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 2), open_price: 3470, high_price: 3485, low_price: 3435, close_price: 3435, volume: 13500, adjusted_close_price: 3435),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 3), open_price: 3420, high_price: 3445, low_price: 3215, close_price: 3260, volume: 61700, adjusted_close_price: 3260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 6), open_price: 3215, high_price: 3300, low_price: 3215, close_price: 3265, volume: 22800, adjusted_close_price: 3265),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 7), open_price: 3305, high_price: 3410, low_price: 3270, close_price: 3405, volume: 33300, adjusted_close_price: 3405),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 8), open_price: 3370, high_price: 3395, low_price: 3305, close_price: 3315, volume: 24700, adjusted_close_price: 3315),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 9), open_price: 3300, high_price: 3310, low_price: 3275, close_price: 3300, volume: 15000, adjusted_close_price: 3300),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 10), open_price: 3325, high_price: 3325, low_price: 3275, close_price: 3290, volume: 20500, adjusted_close_price: 3290),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 13), open_price: 3290, high_price: 3305, low_price: 3225, close_price: 3240, volume: 29600, adjusted_close_price: 3240),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 14), open_price: 3270, high_price: 3320, low_price: 3265, close_price: 3295, volume: 12800, adjusted_close_price: 3295),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 15), open_price: 3295, high_price: 3315, low_price: 3255, close_price: 3275, volume: 8100, adjusted_close_price: 3275),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 16), open_price: 3270, high_price: 3270, low_price: 3210, close_price: 3255, volume: 17000, adjusted_close_price: 3255),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 17), open_price: 3240, high_price: 3275, low_price: 3235, close_price: 3270, volume: 11000, adjusted_close_price: 3270),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 20), open_price: 3290, high_price: 3290, low_price: 3250, close_price: 3255, volume: 13800, adjusted_close_price: 3255),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 21), open_price: 3230, high_price: 3265, low_price: 3220, close_price: 3245, volume: 15700, adjusted_close_price: 3245),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 22), open_price: 3245, high_price: 3295, low_price: 3245, close_price: 3290, volume: 12400, adjusted_close_price: 3290),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 23), open_price: 3280, high_price: 3280, low_price: 3250, close_price: 3250, volume: 10400, adjusted_close_price: 3250),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 24), open_price: 3250, high_price: 3265, low_price: 3250, close_price: 3260, volume: 6800, adjusted_close_price: 3260),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 27), open_price: 3260, high_price: 3260, low_price: 3215, close_price: 3225, volume: 33200, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 28), open_price: 3240, high_price: 3260, low_price: 3225, close_price: 3225, volume: 17800, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 29), open_price: 3225, high_price: 3235, low_price: 3215, close_price: 3220, volume: 16700, adjusted_close_price: 3220),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 30), open_price: 3240, high_price: 3255, low_price: 3195, close_price: 3195, volume: 29900, adjusted_close_price: 3195),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 8, 31), open_price: 3210, high_price: 3210, low_price: 3140, close_price: 3145, volume: 48400, adjusted_close_price: 3145),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 3), open_price: 3150, high_price: 3150, low_price: 3100, close_price: 3115, volume: 31700, adjusted_close_price: 3115),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 4), open_price: 3130, high_price: 3240, low_price: 3120, close_price: 3200, volume: 35700, adjusted_close_price: 3200),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 5), open_price: 3180, high_price: 3215, low_price: 3180, close_price: 3215, volume: 14300, adjusted_close_price: 3215),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 6), open_price: 3195, high_price: 3195, low_price: 3115, close_price: 3120, volume: 30000, adjusted_close_price: 3120),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 7), open_price: 3120, high_price: 3145, low_price: 3085, close_price: 3115, volume: 30900, adjusted_close_price: 3115),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 10), open_price: 3120, high_price: 3150, low_price: 3095, close_price: 3130, volume: 26100, adjusted_close_price: 3130),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 11), open_price: 3125, high_price: 3130, low_price: 3075, close_price: 3095, volume: 29000, adjusted_close_price: 3095),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 12), open_price: 3105, high_price: 3110, low_price: 3070, close_price: 3095, volume: 19600, adjusted_close_price: 3095),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 13), open_price: 3105, high_price: 3160, low_price: 3100, close_price: 3140, volume: 32100, adjusted_close_price: 3140),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 14), open_price: 3190, high_price: 3195, low_price: 3165, close_price: 3185, volume: 29500, adjusted_close_price: 3185),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 18), open_price: 3185, high_price: 3280, low_price: 3180, close_price: 3280, volume: 33700, adjusted_close_price: 3280),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 19), open_price: 3330, high_price: 3350, low_price: 3295, close_price: 3330, volume: 32700, adjusted_close_price: 3330),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 20), open_price: 3350, high_price: 3350, low_price: 3300, close_price: 3320, volume: 16700, adjusted_close_price: 3320),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 21), open_price: 3340, high_price: 3340, low_price: 3265, close_price: 3310, volume: 39400, adjusted_close_price: 3310),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 25), open_price: 3300, high_price: 3385, low_price: 3300, close_price: 3385, volume: 25600, adjusted_close_price: 3385),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 26), open_price: 3420, high_price: 3495, low_price: 3410, close_price: 3485, volume: 35000, adjusted_close_price: 3485),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 27), open_price: 3445, high_price: 3500, low_price: 3390, close_price: 3395, volume: 19500, adjusted_close_price: 3395),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 9, 28), open_price: 3440, high_price: 3445, low_price: 3395, close_price: 3400, volume: 11800, adjusted_close_price: 3400),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 1), open_price: 3415, high_price: 3445, low_price: 3380, close_price: 3380, volume: 14000, adjusted_close_price: 3380),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 2), open_price: 3385, high_price: 3415, low_price: 3360, close_price: 3365, volume: 12800, adjusted_close_price: 3365),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 3), open_price: 3360, high_price: 3370, low_price: 3340, close_price: 3340, volume: 14900, adjusted_close_price: 3340),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 4), open_price: 3340, high_price: 3365, low_price: 3320, close_price: 3330, volume: 9300, adjusted_close_price: 3330),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 5), open_price: 3300, high_price: 3340, low_price: 3300, close_price: 3315, volume: 12600, adjusted_close_price: 3315),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 9), open_price: 3295, high_price: 3295, low_price: 3230, close_price: 3245, volume: 15000, adjusted_close_price: 3245),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 10), open_price: 3235, high_price: 3325, low_price: 3235, close_price: 3300, volume: 13600, adjusted_close_price: 3300),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 11), open_price: 3190, high_price: 3225, low_price: 3175, close_price: 3195, volume: 28100, adjusted_close_price: 3195),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 12), open_price: 3170, high_price: 3205, low_price: 3145, close_price: 3175, volume: 25800, adjusted_close_price: 3175),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 15), open_price: 3185, high_price: 3185, low_price: 3115, close_price: 3115, volume: 22700, adjusted_close_price: 3115),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 16), open_price: 3110, high_price: 3125, low_price: 3080, close_price: 3120, volume: 19600, adjusted_close_price: 3120),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 17), open_price: 3150, high_price: 3165, low_price: 3115, close_price: 3135, volume: 23300, adjusted_close_price: 3135),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 18), open_price: 3135, high_price: 3170, low_price: 3135, close_price: 3145, volume: 12200, adjusted_close_price: 3145),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 19), open_price: 3145, high_price: 3145, low_price: 3100, close_price: 3110, volume: 24000, adjusted_close_price: 3110),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 22), open_price: 3120, high_price: 3140, low_price: 3100, close_price: 3110, volume: 24400, adjusted_close_price: 3110),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 23), open_price: 3120, high_price: 3120, low_price: 3055, close_price: 3055, volume: 38100, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 24), open_price: 3065, high_price: 3155, low_price: 3060, close_price: 3145, volume: 23100, adjusted_close_price: 3145),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 25), open_price: 3085, high_price: 3085, low_price: 3025, close_price: 3030, volume: 39700, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 26), open_price: 3080, high_price: 3080, low_price: 3015, close_price: 3070, volume: 33100, adjusted_close_price: 3070),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 29), open_price: 3070, high_price: 3090, low_price: 2997, close_price: 2997, volume: 32700, adjusted_close_price: 2997),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 30), open_price: 2995, high_price: 3025, low_price: 2981, close_price: 3005, volume: 27400, adjusted_close_price: 3005),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 31), open_price: 3025, high_price: 3105, low_price: 3025, close_price: 3095, volume: 26000, adjusted_close_price: 3095),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 1), open_price: 3100, high_price: 3105, low_price: 3070, close_price: 3090, volume: 16000, adjusted_close_price: 3090),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 2), open_price: 3100, high_price: 3130, low_price: 3055, close_price: 3110, volume: 31900, adjusted_close_price: 3110),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 5), open_price: 3100, high_price: 3100, low_price: 3015, close_price: 3025, volume: 38500, adjusted_close_price: 3025),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 6), open_price: 3015, high_price: 3115, low_price: 3010, close_price: 3045, volume: 30700, adjusted_close_price: 3045),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 7), open_price: 3045, high_price: 3080, low_price: 3010, close_price: 3020, volume: 35000, adjusted_close_price: 3020),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 8), open_price: 3060, high_price: 3085, low_price: 3050, close_price: 3065, volume: 18300, adjusted_close_price: 3065),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 9), open_price: 3055, high_price: 3100, low_price: 3045, close_price: 3055, volume: 29300, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 12), open_price: 3065, high_price: 3175, low_price: 3065, close_price: 3160, volume: 39400, adjusted_close_price: 3160),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 13), open_price: 3090, high_price: 3100, low_price: 3030, close_price: 3040, volume: 35700, adjusted_close_price: 3040),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 14), open_price: 3050, high_price: 3060, low_price: 3000, close_price: 3010, volume: 51200, adjusted_close_price: 3010),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 15), open_price: 3005, high_price: 3025, low_price: 2995, close_price: 3015, volume: 33900, adjusted_close_price: 3015),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 16), open_price: 3025, high_price: 3025, low_price: 3005, close_price: 3010, volume: 36500, adjusted_close_price: 3010),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 19), open_price: 3010, high_price: 3035, low_price: 2983, close_price: 3030, volume: 51500, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 20), open_price: 3035, high_price: 3100, low_price: 3020, close_price: 3075, volume: 34300, adjusted_close_price: 3075),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 21), open_price: 2989, high_price: 3050, low_price: 2987, close_price: 3040, volume: 21800, adjusted_close_price: 3040),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 22), open_price: 3035, high_price: 3070, low_price: 3010, close_price: 3065, volume: 21200, adjusted_close_price: 3065),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 26), open_price: 3060, high_price: 3105, low_price: 3055, close_price: 3100, volume: 30300, adjusted_close_price: 3100),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 27), open_price: 3110, high_price: 3165, low_price: 3110, close_price: 3150, volume: 23900, adjusted_close_price: 3150),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 28), open_price: 3165, high_price: 3170, low_price: 3130, close_price: 3155, volume: 16400, adjusted_close_price: 3155),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 29), open_price: 3185, high_price: 3250, low_price: 3185, close_price: 3215, volume: 36100, adjusted_close_price: 3215),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 30), open_price: 3245, high_price: 3245, low_price: 3195, close_price: 3225, volume: 25700, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 3), open_price: 3225, high_price: 3335, low_price: 3225, close_price: 3320, volume: 43300, adjusted_close_price: 3320),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 4), open_price: 3320, high_price: 3320, low_price: 3250, close_price: 3250, volume: 30600, adjusted_close_price: 3250),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 5), open_price: 3190, high_price: 3240, low_price: 3165, close_price: 3235, volume: 20800, adjusted_close_price: 3235),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 6), open_price: 3195, high_price: 3200, low_price: 3170, close_price: 3180, volume: 19800, adjusted_close_price: 3180),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 7), open_price: 3230, high_price: 3235, low_price: 3165, close_price: 3225, volume: 20700, adjusted_close_price: 3225),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 10), open_price: 3185, high_price: 3185, low_price: 3105, close_price: 3105, volume: 20500, adjusted_close_price: 3105),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 11), open_price: 3110, high_price: 3115, low_price: 3030, close_price: 3030, volume: 21400, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 12), open_price: 3035, high_price: 3080, low_price: 3035, close_price: 3055, volume: 13400, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 13), open_price: 3080, high_price: 3090, low_price: 3055, close_price: 3085, volume: 21400, adjusted_close_price: 3085),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 14), open_price: 3085, high_price: 3110, low_price: 3050, close_price: 3055, volume: 21400, adjusted_close_price: 3055),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 17), open_price: 3035, high_price: 3040, low_price: 3020, close_price: 3030, volume: 14400, adjusted_close_price: 3030),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 18), open_price: 3005, high_price: 3010, low_price: 2975, close_price: 2975, volume: 32400, adjusted_close_price: 2975),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 19), open_price: 2972, high_price: 2986, low_price: 2943, close_price: 2963, volume: 19800, adjusted_close_price: 2963),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 20), open_price: 2940, high_price: 2950, low_price: 2853, close_price: 2872, volume: 33400, adjusted_close_price: 2872),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 21), open_price: 2852, high_price: 2852, low_price: 2741, close_price: 2745, volume: 55600, adjusted_close_price: 2745),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 25), open_price: 2624, high_price: 2650, low_price: 2581, close_price: 2607, volume: 54900, adjusted_close_price: 2607),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 26), open_price: 2630, high_price: 2753, low_price: 2630, close_price: 2699, volume: 30400, adjusted_close_price: 2699),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 27), open_price: 2820, high_price: 2893, low_price: 2784, close_price: 2874, volume: 33300, adjusted_close_price: 2874),
          have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 28), open_price: 2874, high_price: 2908, low_price: 2840, close_price: 2882, volume: 24400, adjusted_close_price: 2882),
        ])
      end
    end
  end
end

