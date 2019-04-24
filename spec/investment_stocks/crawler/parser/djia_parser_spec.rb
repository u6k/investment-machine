require "timecop"
require "webmock/rspec"

RSpec.describe InvestmentStocks::Crawler::Parser::DjiaIndexPageParser do
  before do
    WebMock.enable!

    url = "https://quotes.wsj.com/index/DJIA/historical-prices/"
    WebMock.stub_request(:get, url).to_return(
      status: [200, "OK"],
      body: "test")

    downloader = Crawline::Downloader.new("investment-stocks-crawler/#{InvestmentStocks::Crawler::VERSION}")

    Timecop.freeze(Time.utc(2018, 4, 5, 16, 42, 48)) do
      @parser = InvestmentStocks::Crawler::Parser::DjiaIndexPageParser.new(url, downloader.download_with_get(url))
    end

    WebMock.disable!
  end

  describe "#redownload?" do
    it "always redownload" do
      expect(@parser).to be_redownload
    end
  end

  describe "#valid?" do
    it "always valid" do
      expect(@parser).to be_valid
    end
  end

  describe "#related_links" do
    it "is download links" do
      expect(@parser.related_links).to contain_exactly(
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1990&endDate=12/31/1990",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1991&endDate=12/31/1991",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1992&endDate=12/31/1992",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1993&endDate=12/31/1993",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1994&endDate=12/31/1994",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1995&endDate=12/31/1995",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1996&endDate=12/31/1996",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1997&endDate=12/31/1997",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1998&endDate=12/31/1998",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1999&endDate=12/31/1999",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2000&endDate=12/31/2000",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2001&endDate=12/31/2001",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2002&endDate=12/31/2002",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2003&endDate=12/31/2003",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2004&endDate=12/31/2004",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2005&endDate=12/31/2005",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2006&endDate=12/31/2006",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2007&endDate=12/31/2007",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2008&endDate=12/31/2008",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2009&endDate=12/31/2009",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2010&endDate=12/31/2010",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2011&endDate=12/31/2011",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2012&endDate=12/31/2012",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2013&endDate=12/31/2013",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2014&endDate=12/31/2014",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2015&endDate=12/31/2015",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2016&endDate=12/31/2016",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2017&endDate=12/31/2017",
        "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2018&endDate=12/31/2018")
    end
  end

  describe "#parse" do
    it "is empty" do
      context = {}

      @parser.parse(context)

      expect(context).to be_empty
    end
  end
end

RSpec.describe InvestmentStocks::Crawler::Parser::DjiaCsvParser do
  before do
    # Cleanup database
    InvestmentStocks::Crawler::Model::Djia.delete_all

    # Setup webmock
    WebMock.enable!

    @url_1990 = "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1990&endDate=12/31/1990"
    WebMock.stub_request(:get, @url_1990).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/djia.1990.csv").read)

    @url_2019 = "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2019&endDate=12/31/2019"
    WebMock.stub_request(:get, @url_2019).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/djia.2019.csv").read)

    # Setup parser
    @downloader = Crawline::Downloader.new("investment-stocks-crawler/#{InvestmentStocks::Crawler::VERSION}")

    @parser_1990 = InvestmentStocks::Crawler::Parser::DjiaCsvParser.new(@url_1990, @downloader.download_with_get(@url_1990))
    @parser_2019 = InvestmentStocks::Crawler::Parser::DjiaCsvParser.new(@url_2019, @downloader.download_with_get(@url_2019))

    WebMock.disable!
  end

  describe "#redownload?" do
    context "1990s" do
      it "redownload if newer than 2 years" do
        Timecop.freeze(Time.local(1991, 12, 31, 23, 59, 59)) do
          expect(@parser_1990).to be_redownload
        end
      end

      it "do not redownload if over 2 years" do
        Timecop.freeze(Time.local(1992, 1, 1, 0, 0, 0)) do
          expect(@parser_1990).not_to be_redownload
        end
      end
    end

    context "2019s" do
      it "redownload if newer than 2 years" do
        Timecop.freeze(Time.local(2020, 12, 31, 23, 59, 59)) do
          expect(@parser_2019).to be_redownload
        end
      end

      it "do not redownload if over 2 years" do
        Timecop.freeze(Time.local(2021, 1, 1, 0, 0, 0)) do
          expect(@parser_2019).not_to be_redownload
        end
      end
    end
  end

  describe "#valid?" do
    context "1990s" do
      it "is valid" do
        expect(@parser_1990).to be_valid
      end
    end

    context "1990s on web" do
      it "is valid" do
        data = @downloader.download_with_get(@url_1990)

        parser = InvestmentStocks::Crawler::Parser::DjiaCsvParser.new(@url_1990, data)

        expect(parser).to be_valid
      end
    end

    context "2019s" do
      it "is valid" do
        expect(@parser_2019).to be_valid
      end
    end

    context "2019s on web" do
      it "is valid" do
        data = @downloader.download_with_get(@url_2019)

        parser = InvestmentStocks::Crawler::Parser::DjiaCsvParser.new(@url_2019, data)

        expect(parser).to be_valid
      end
    end
  end

  describe "#related_links" do
    context "1990s" do
      it "is nil" do
        expect(@parser_1990.related_links).to be_nil
      end
    end

    context "2019s" do
      it "is nil" do
        expect(@parser_2019.related_links).to be_nil
      end
    end
  end

  describe "#parse" do
    context "1990s" do
      it "is prices" do
        context = {}

        @parser_1990.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::Djia.all).to match_array([
          have_attributes(date: Time.local(1990, 1, 2), opening_price: 2810.15, high_price: 2811.65, low_price: 2732.51, close_price: 2810.15),
          have_attributes(date: Time.local(1990, 1, 3), opening_price: 2809.73, high_price: 2834.04, low_price: 2786.26, close_price: 2809.73),
          have_attributes(date: Time.local(1990, 1, 4), opening_price: 2796.08, high_price: 2821.46, low_price: 2766.42, close_price: 2796.08),
          have_attributes(date: Time.local(1990, 1, 5), opening_price: 2773.25, high_price: 2810.15, low_price: 2758.11, close_price: 2773.25),
          have_attributes(date: Time.local(1990, 1, 8), opening_price: 2794.37, high_price: 2803.97, low_price: 2753.41, close_price: 2794.37),
          have_attributes(date: Time.local(1990, 1, 9), opening_price: 2766.00, high_price: 2810.79, low_price: 2760.03, close_price: 2766.00),
          have_attributes(date: Time.local(1990, 1, 10), opening_price: 2750.64, high_price: 2772.82, low_price: 2725.47, close_price: 2750.64),
          have_attributes(date: Time.local(1990, 1, 11), opening_price: 2760.67, high_price: 2774.74, low_price: 2751.07, close_price: 2760.67),
          have_attributes(date: Time.local(1990, 1, 12), opening_price: 2689.21, high_price: 2735.92, low_price: 2675.98, close_price: 2689.21),
          have_attributes(date: Time.local(1990, 1, 15), opening_price: 2669.37, high_price: 2692.41, low_price: 2666.17, close_price: 2669.37),
          have_attributes(date: Time.local(1990, 1, 16), opening_price: 2692.62, high_price: 2698.38, low_price: 2634.17, close_price: 2692.62),
          have_attributes(date: Time.local(1990, 1, 17), opening_price: 2659.13, high_price: 2711.39, low_price: 2643.77, close_price: 2659.13),
          have_attributes(date: Time.local(1990, 1, 18), opening_price: 2666.38, high_price: 2678.11, low_price: 2625.85, close_price: 2666.38),
          have_attributes(date: Time.local(1990, 1, 19), opening_price: 2677.90, high_price: 2696.89, low_price: 2657.85, close_price: 2677.90),
          have_attributes(date: Time.local(1990, 1, 22), opening_price: 2600.45, high_price: 2683.33, low_price: 2595.27, close_price: 2600.45),
          have_attributes(date: Time.local(1990, 1, 23), opening_price: 2615.32, high_price: 2639.64, low_price: 2584.01, close_price: 2615.32),
          have_attributes(date: Time.local(1990, 1, 24), opening_price: 2604.50, high_price: 2619.59, low_price: 2534.23, close_price: 2604.50),
          have_attributes(date: Time.local(1990, 1, 25), opening_price: 2561.04, high_price: 2628.83, low_price: 2546.17, close_price: 2561.04),
          have_attributes(date: Time.local(1990, 1, 26), opening_price: 2559.23, high_price: 2591.67, low_price: 2516.89, close_price: 2559.23),
          have_attributes(date: Time.local(1990, 1, 29), opening_price: 2553.38, high_price: 2583.56, low_price: 2522.97, close_price: 2553.38),
          have_attributes(date: Time.local(1990, 1, 30), opening_price: 2543.24, high_price: 2576.13, low_price: 2513.06, close_price: 2543.24),
          have_attributes(date: Time.local(1990, 1, 31), opening_price: 2590.54, high_price: 2600.90, low_price: 2546.85, close_price: 2590.54),
          have_attributes(date: Time.local(1990, 2, 1), opening_price: 2586.26, high_price: 2611.49, low_price: 2571.85, close_price: 2586.26),
          have_attributes(date: Time.local(1990, 2, 2), opening_price: 2602.70, high_price: 2623.65, low_price: 2577.03, close_price: 2602.70),
          have_attributes(date: Time.local(1990, 2, 5), opening_price: 2622.52, high_price: 2633.56, low_price: 2592.12, close_price: 2622.52),
          have_attributes(date: Time.local(1990, 2, 6), opening_price: 2606.31, high_price: 2629.50, low_price: 2588.29, close_price: 2606.31),
          have_attributes(date: Time.local(1990, 2, 7), opening_price: 2640.09, high_price: 2651.35, low_price: 2579.28, close_price: 2640.09),
          have_attributes(date: Time.local(1990, 2, 8), opening_price: 2644.37, high_price: 2674.32, low_price: 2622.30, close_price: 2644.37),
          have_attributes(date: Time.local(1990, 2, 9), opening_price: 2648.20, high_price: 2666.67, low_price: 2628.15, close_price: 2648.20),
          have_attributes(date: Time.local(1990, 2, 12), opening_price: 2619.14, high_price: 2652.48, low_price: 2610.59, close_price: 2619.14),
          have_attributes(date: Time.local(1990, 2, 13), opening_price: 2624.10, high_price: 2639.19, low_price: 2592.57, close_price: 2624.10),
          have_attributes(date: Time.local(1990, 2, 14), opening_price: 2624.32, high_price: 2643.69, low_price: 2608.11, close_price: 2624.32),
          have_attributes(date: Time.local(1990, 2, 15), opening_price: 2649.55, high_price: 2658.78, low_price: 2614.86, close_price: 2649.55),
          have_attributes(date: Time.local(1990, 2, 16), opening_price: 2635.59, high_price: 2669.37, low_price: 2623.65, close_price: 2635.59),
          have_attributes(date: Time.local(1990, 2, 20), opening_price: 2596.85, high_price: 2619.14, low_price: 2579.05, close_price: 2596.85),
          have_attributes(date: Time.local(1990, 2, 21), opening_price: 2583.56, high_price: 2602.48, low_price: 2556.31, close_price: 2583.56),
          have_attributes(date: Time.local(1990, 2, 22), opening_price: 2574.77, high_price: 2622.30, low_price: 2568.02, close_price: 2574.77),
          have_attributes(date: Time.local(1990, 2, 23), opening_price: 2564.19, high_price: 2591.44, low_price: 2540.99, close_price: 2564.19),
          have_attributes(date: Time.local(1990, 2, 26), opening_price: 2602.48, high_price: 2606.31, low_price: 2560.14, close_price: 2602.48),
          have_attributes(date: Time.local(1990, 2, 27), opening_price: 2617.12, high_price: 2637.84, low_price: 2592.12, close_price: 2617.12),
          have_attributes(date: Time.local(1990, 2, 28), opening_price: 2627.25, high_price: 2652.48, low_price: 2603.60, close_price: 2627.25),
          have_attributes(date: Time.local(1990, 3, 1), opening_price: 2635.59, high_price: 2655.63, low_price: 2607.88, close_price: 2635.59),
          have_attributes(date: Time.local(1990, 3, 2), opening_price: 2660.36, high_price: 2669.82, low_price: 2630.18, close_price: 2660.36),
          have_attributes(date: Time.local(1990, 3, 5), opening_price: 2649.55, high_price: 2675.23, low_price: 2636.71, close_price: 2649.55),
          have_attributes(date: Time.local(1990, 3, 6), opening_price: 2676.80, high_price: 2684.46, low_price: 2638.06, close_price: 2676.80),
          have_attributes(date: Time.local(1990, 3, 7), opening_price: 2669.59, high_price: 2696.85, low_price: 2656.08, close_price: 2669.59),
          have_attributes(date: Time.local(1990, 3, 8), opening_price: 2696.17, high_price: 2705.18, low_price: 2661.26, close_price: 2696.17),
          have_attributes(date: Time.local(1990, 3, 9), opening_price: 2683.33, high_price: 2705.63, low_price: 2665.54, close_price: 2683.33),
          have_attributes(date: Time.local(1990, 3, 12), opening_price: 2686.71, high_price: 2698.65, low_price: 2661.94, close_price: 2686.71),
          have_attributes(date: Time.local(1990, 3, 13), opening_price: 2674.55, high_price: 2699.55, low_price: 2657.88, close_price: 2674.55),
          have_attributes(date: Time.local(1990, 3, 14), opening_price: 2687.84, high_price: 2705.18, low_price: 2662.39, close_price: 2687.84),
          have_attributes(date: Time.local(1990, 3, 15), opening_price: 2695.72, high_price: 2714.86, low_price: 2677.93, close_price: 2695.72),
          have_attributes(date: Time.local(1990, 3, 16), opening_price: 2741.22, high_price: 2745.50, low_price: 2699.32, close_price: 2741.22),
          have_attributes(date: Time.local(1990, 3, 19), opening_price: 2755.63, high_price: 2761.71, low_price: 2706.53, close_price: 2755.63),
          have_attributes(date: Time.local(1990, 3, 20), opening_price: 2738.74, high_price: 2775.00, low_price: 2724.10, close_price: 2738.74),
          have_attributes(date: Time.local(1990, 3, 21), opening_price: 2727.93, high_price: 2759.68, low_price: 2718.24, close_price: 2727.93),
          have_attributes(date: Time.local(1990, 3, 22), opening_price: 2695.72, high_price: 2734.01, low_price: 2674.32, close_price: 2695.72),
          have_attributes(date: Time.local(1990, 3, 23), opening_price: 2704.28, high_price: 2722.75, low_price: 2688.06, close_price: 2704.28),
          have_attributes(date: Time.local(1990, 3, 26), opening_price: 2707.66, high_price: 2735.81, low_price: 2697.97, close_price: 2707.66),
          have_attributes(date: Time.local(1990, 3, 27), opening_price: 2736.94, high_price: 2738.96, low_price: 2691.89, close_price: 2736.94),
          have_attributes(date: Time.local(1990, 3, 28), opening_price: 2743.69, high_price: 2755.63, low_price: 2716.22, close_price: 2743.69),
          have_attributes(date: Time.local(1990, 3, 29), opening_price: 2727.70, high_price: 2753.38, low_price: 2711.49, close_price: 2727.70),
          have_attributes(date: Time.local(1990, 3, 30), opening_price: 2707.21, high_price: 2736.72, low_price: 2692.34, close_price: 2707.21),
          have_attributes(date: Time.local(1990, 4, 2), opening_price: 2700.45, high_price: 2708.78, low_price: 2668.69, close_price: 2700.45),
          have_attributes(date: Time.local(1990, 4, 3), opening_price: 2736.71, high_price: 2747.30, low_price: 2699.55, close_price: 2736.71),
          have_attributes(date: Time.local(1990, 4, 4), opening_price: 2719.37, high_price: 2755.86, low_price: 2708.56, close_price: 2719.37),
          have_attributes(date: Time.local(1990, 4, 5), opening_price: 2721.17, high_price: 2746.17, low_price: 2709.01, close_price: 2721.17),
          have_attributes(date: Time.local(1990, 4, 6), opening_price: 2717.12, high_price: 2732.43, low_price: 2695.50, close_price: 2717.12),
          have_attributes(date: Time.local(1990, 4, 9), opening_price: 2722.07, high_price: 2737.39, low_price: 2701.35, close_price: 2722.07),
          have_attributes(date: Time.local(1990, 4, 10), opening_price: 2731.08, high_price: 2741.67, low_price: 2707.88, close_price: 2731.08),
          have_attributes(date: Time.local(1990, 4, 11), opening_price: 2729.73, high_price: 2751.35, low_price: 2713.29, close_price: 2729.73),
          have_attributes(date: Time.local(1990, 4, 12), opening_price: 2751.80, high_price: 2763.96, low_price: 2729.05, close_price: 2751.80),
          have_attributes(date: Time.local(1990, 4, 16), opening_price: 2763.06, high_price: 2793.47, low_price: 2748.87, close_price: 2763.06),
          have_attributes(date: Time.local(1990, 4, 17), opening_price: 2765.77, high_price: 2774.77, low_price: 2738.29, close_price: 2765.77),
          have_attributes(date: Time.local(1990, 4, 18), opening_price: 2732.88, high_price: 2771.85, low_price: 2727.48, close_price: 2732.88),
          have_attributes(date: Time.local(1990, 4, 19), opening_price: 2711.94, high_price: 2742.12, low_price: 2700.00, close_price: 2711.94),
          have_attributes(date: Time.local(1990, 4, 20), opening_price: 2695.95, high_price: 2722.07, low_price: 2668.47, close_price: 2695.95),
          have_attributes(date: Time.local(1990, 4, 23), opening_price: 2666.67, high_price: 2690.77, low_price: 2650.90, close_price: 2666.67),
          have_attributes(date: Time.local(1990, 4, 24), opening_price: 2654.50, high_price: 2686.04, low_price: 2643.69, close_price: 2654.50),
          have_attributes(date: Time.local(1990, 4, 25), opening_price: 2666.44, high_price: 2685.36, low_price: 2649.32, close_price: 2666.44),
          have_attributes(date: Time.local(1990, 4, 26), opening_price: 2676.58, high_price: 2691.89, low_price: 2650.23, close_price: 2676.58),
          have_attributes(date: Time.local(1990, 4, 27), opening_price: 2645.05, high_price: 2687.39, low_price: 2639.19, close_price: 2645.05),
          have_attributes(date: Time.local(1990, 4, 30), opening_price: 2656.76, high_price: 2667.79, low_price: 2627.70, close_price: 2656.76),
          have_attributes(date: Time.local(1990, 5, 1), opening_price: 2668.92, high_price: 2687.39, low_price: 2651.35, close_price: 2668.92),
          have_attributes(date: Time.local(1990, 5, 2), opening_price: 2689.64, high_price: 2697.30, low_price: 2659.01, close_price: 2689.64),
          have_attributes(date: Time.local(1990, 5, 3), opening_price: 2696.17, high_price: 2716.22, low_price: 2682.88, close_price: 2696.17),
          have_attributes(date: Time.local(1990, 5, 4), opening_price: 2710.36, high_price: 2718.92, low_price: 2682.43, close_price: 2710.36),
          have_attributes(date: Time.local(1990, 5, 7), opening_price: 2721.62, high_price: 2739.19, low_price: 2698.87, close_price: 2721.62),
          have_attributes(date: Time.local(1990, 5, 8), opening_price: 2733.56, high_price: 2739.41, low_price: 2710.36, close_price: 2733.56),
          have_attributes(date: Time.local(1990, 5, 9), opening_price: 2732.88, high_price: 2745.50, low_price: 2710.14, close_price: 2732.88),
          have_attributes(date: Time.local(1990, 5, 10), opening_price: 2738.51, high_price: 2755.63, low_price: 2716.44, close_price: 2738.51),
          have_attributes(date: Time.local(1990, 5, 11), opening_price: 2801.58, high_price: 2810.36, low_price: 2743.02, close_price: 2801.58),
          have_attributes(date: Time.local(1990, 5, 14), opening_price: 2821.53, high_price: 2857.87, low_price: 2793.75, close_price: 2821.53),
          have_attributes(date: Time.local(1990, 5, 15), opening_price: 2822.45, high_price: 2840.74, low_price: 2798.15, close_price: 2822.45),
          have_attributes(date: Time.local(1990, 5, 16), opening_price: 2819.68, high_price: 2841.44, low_price: 2800.23, close_price: 2819.68),
          have_attributes(date: Time.local(1990, 5, 17), opening_price: 2831.71, high_price: 2856.25, low_price: 2811.57, close_price: 2831.71),
          have_attributes(date: Time.local(1990, 5, 18), opening_price: 2819.91, high_price: 2838.43, low_price: 2804.63, close_price: 2819.91),
          have_attributes(date: Time.local(1990, 5, 21), opening_price: 2844.68, high_price: 2859.72, low_price: 2802.08, close_price: 2844.68),
          have_attributes(date: Time.local(1990, 5, 22), opening_price: 2852.23, high_price: 2877.13, low_price: 2828.51, close_price: 2852.23),
          have_attributes(date: Time.local(1990, 5, 23), opening_price: 2856.26, high_price: 2869.07, low_price: 2824.95, close_price: 2856.26),
          have_attributes(date: Time.local(1990, 5, 24), opening_price: 2855.55, high_price: 2878.08, low_price: 2828.04, close_price: 2855.55),
          have_attributes(date: Time.local(1990, 5, 25), opening_price: 2820.92, high_price: 2856.50, low_price: 2806.69, close_price: 2820.92),
          have_attributes(date: Time.local(1990, 5, 29), opening_price: 2870.49, high_price: 2876.19, low_price: 2812.62, close_price: 2870.49),
          have_attributes(date: Time.local(1990, 5, 30), opening_price: 2878.56, high_price: 2908.21, low_price: 2853.89, close_price: 2878.56),
          have_attributes(date: Time.local(1990, 5, 31), opening_price: 2876.66, high_price: 2900.62, low_price: 2854.84, close_price: 2876.66),
          have_attributes(date: Time.local(1990, 6, 1), opening_price: 2900.97, high_price: 2919.90, low_price: 2868.69, close_price: 2900.97),
          have_attributes(date: Time.local(1990, 6, 4), opening_price: 2935.19, high_price: 2943.69, low_price: 2883.98, close_price: 2935.19),
          have_attributes(date: Time.local(1990, 6, 5), opening_price: 2925.00, high_price: 2956.55, low_price: 2911.89, close_price: 2925.00),
          have_attributes(date: Time.local(1990, 6, 6), opening_price: 2911.65, high_price: 2936.65, low_price: 2891.99, close_price: 2911.65),
          have_attributes(date: Time.local(1990, 6, 7), opening_price: 2897.33, high_price: 2930.58, low_price: 2880.34, close_price: 2897.33),
          have_attributes(date: Time.local(1990, 6, 8), opening_price: 2862.38, high_price: 2908.50, low_price: 2850.73, close_price: 2862.38),
          have_attributes(date: Time.local(1990, 6, 11), opening_price: 2892.57, high_price: 2901.98, low_price: 2852.97, close_price: 2892.57),
          have_attributes(date: Time.local(1990, 6, 12), opening_price: 2933.42, high_price: 2947.52, low_price: 2877.97, close_price: 2933.42),
          have_attributes(date: Time.local(1990, 6, 13), opening_price: 2929.95, high_price: 2956.93, low_price: 2910.15, close_price: 2929.95),
          have_attributes(date: Time.local(1990, 6, 14), opening_price: 2928.22, high_price: 2943.56, low_price: 2902.97, close_price: 2928.22),
          have_attributes(date: Time.local(1990, 6, 15), opening_price: 2935.89, high_price: 2947.77, low_price: 2902.72, close_price: 2935.89),
          have_attributes(date: Time.local(1990, 6, 18), opening_price: 2882.18, high_price: 2930.45, low_price: 2877.48, close_price: 2882.18),
          have_attributes(date: Time.local(1990, 6, 19), opening_price: 2893.56, high_price: 2907.92, low_price: 2866.58, close_price: 2893.56),
          have_attributes(date: Time.local(1990, 6, 20), opening_price: 2895.30, high_price: 2914.60, low_price: 2868.81, close_price: 2895.30),
          have_attributes(date: Time.local(1990, 6, 21), opening_price: 2901.73, high_price: 2916.58, low_price: 2870.05, close_price: 2901.73),
          have_attributes(date: Time.local(1990, 6, 22), opening_price: 2857.18, high_price: 2931.93, low_price: 2848.02, close_price: 2857.18),
          have_attributes(date: Time.local(1990, 6, 25), opening_price: 2845.05, high_price: 2882.18, low_price: 2835.15, close_price: 2845.05),
          have_attributes(date: Time.local(1990, 6, 26), opening_price: 2842.33, high_price: 2882.92, low_price: 2832.67, close_price: 2842.33),
          have_attributes(date: Time.local(1990, 6, 27), opening_price: 2862.13, high_price: 2878.96, low_price: 2821.53, close_price: 2862.13),
          have_attributes(date: Time.local(1990, 6, 28), opening_price: 2878.71, high_price: 2896.04, low_price: 2850.50, close_price: 2878.71),
          have_attributes(date: Time.local(1990, 6, 29), opening_price: 2880.69, high_price: 2901.98, low_price: 2865.84, close_price: 2880.69),
          have_attributes(date: Time.local(1990, 7, 2), opening_price: 2899.26, high_price: 2908.66, low_price: 2869.80, close_price: 2899.26),
          have_attributes(date: Time.local(1990, 7, 3), opening_price: 2911.63, high_price: 2925.74, low_price: 2891.09, close_price: 2911.63),
          have_attributes(date: Time.local(1990, 7, 5), opening_price: 2879.21, high_price: 2906.44, low_price: 2863.61, close_price: 2879.21),
          have_attributes(date: Time.local(1990, 7, 6), opening_price: 2904.95, high_price: 2919.80, low_price: 2867.57, close_price: 2904.95),
          have_attributes(date: Time.local(1990, 7, 9), opening_price: 2914.11, high_price: 2927.97, low_price: 2890.84, close_price: 2914.11),
          have_attributes(date: Time.local(1990, 7, 10), opening_price: 2890.84, high_price: 2928.22, low_price: 2882.18, close_price: 2890.84),
          have_attributes(date: Time.local(1990, 7, 11), opening_price: 2932.67, high_price: 2942.32, low_price: 2890.10, close_price: 2932.67),
          have_attributes(date: Time.local(1990, 7, 12), opening_price: 2969.80, high_price: 2980.69, low_price: 2917.82, close_price: 2969.80),
          have_attributes(date: Time.local(1990, 7, 13), opening_price: 2980.20, high_price: 3012.38, low_price: 2956.68, close_price: 2980.20),
          have_attributes(date: Time.local(1990, 7, 16), opening_price: 2999.75, high_price: 3017.08, low_price: 2971.78, close_price: 2999.75),
          have_attributes(date: Time.local(1990, 7, 17), opening_price: 2999.75, high_price: 3024.56, low_price: 2970.05, close_price: 2999.75),
          have_attributes(date: Time.local(1990, 7, 18), opening_price: 2981.68, high_price: 3009.65, low_price: 2963.61, close_price: 2981.68),
          have_attributes(date: Time.local(1990, 7, 19), opening_price: 2993.81, high_price: 2993.81, low_price: 2958.17, close_price: 2993.81),
          have_attributes(date: Time.local(1990, 7, 20), opening_price: 2961.14, high_price: 3019.31, low_price: 2953.71, close_price: 2961.14),
          have_attributes(date: Time.local(1990, 7, 23), opening_price: 2904.70, high_price: 2961.39, low_price: 2833.17, close_price: 2904.70),
          have_attributes(date: Time.local(1990, 7, 24), opening_price: 2922.52, high_price: 2939.60, low_price: 2866.83, close_price: 2922.52),
          have_attributes(date: Time.local(1990, 7, 25), opening_price: 2930.94, high_price: 2946.53, low_price: 2896.78, close_price: 2930.94),
          have_attributes(date: Time.local(1990, 7, 26), opening_price: 2920.79, high_price: 2945.79, low_price: 2888.12, close_price: 2920.79),
          have_attributes(date: Time.local(1990, 7, 27), opening_price: 2898.51, high_price: 2938.37, low_price: 2877.72, close_price: 2898.51),
          have_attributes(date: Time.local(1990, 7, 30), opening_price: 2917.33, high_price: 2922.52, low_price: 2861.14, close_price: 2917.33),
          have_attributes(date: Time.local(1990, 7, 31), opening_price: 2905.20, high_price: 2940.10, low_price: 2878.47, close_price: 2905.20),
          have_attributes(date: Time.local(1990, 8, 1), opening_price: 2899.26, high_price: 2931.19, low_price: 2875.00, close_price: 2899.26),
          have_attributes(date: Time.local(1990, 8, 2), opening_price: 2864.60, high_price: 2903.71, low_price: 2833.17, close_price: 2864.60),
          have_attributes(date: Time.local(1990, 8, 3), opening_price: 2809.65, high_price: 2863.86, low_price: 2722.03, close_price: 2809.65),
          have_attributes(date: Time.local(1990, 8, 6), opening_price: 2716.34, high_price: 2758.42, low_price: 2683.17, close_price: 2716.34),
          have_attributes(date: Time.local(1990, 8, 7), opening_price: 2710.64, high_price: 2763.86, low_price: 2676.24, close_price: 2710.64),
          have_attributes(date: Time.local(1990, 8, 8), opening_price: 2734.90, high_price: 2763.37, low_price: 2691.34, close_price: 2734.90),
          have_attributes(date: Time.local(1990, 8, 9), opening_price: 2758.91, high_price: 2774.26, low_price: 2716.58, close_price: 2758.91),
          have_attributes(date: Time.local(1990, 8, 10), opening_price: 2716.58, high_price: 2763.61, low_price: 2692.82, close_price: 2716.58),
          have_attributes(date: Time.local(1990, 8, 13), opening_price: 2746.78, high_price: 2752.23, low_price: 2676.73, close_price: 2746.78),
          have_attributes(date: Time.local(1990, 8, 14), opening_price: 2747.77, high_price: 2773.02, low_price: 2720.54, close_price: 2747.77),
          have_attributes(date: Time.local(1990, 8, 15), opening_price: 2748.27, high_price: 2769.55, low_price: 2736.39, close_price: 2748.27),
          have_attributes(date: Time.local(1990, 8, 16), opening_price: 2681.44, high_price: 2746.53, low_price: 2676.24, close_price: 2681.44),
          have_attributes(date: Time.local(1990, 8, 17), opening_price: 2644.80, high_price: 2679.21, low_price: 2598.02, close_price: 2644.80),
          have_attributes(date: Time.local(1990, 8, 20), opening_price: 2656.44, high_price: 2669.31, low_price: 2632.43, close_price: 2656.44),
          have_attributes(date: Time.local(1990, 8, 21), opening_price: 2603.96, high_price: 2645.30, low_price: 2566.90, close_price: 2603.96),
          have_attributes(date: Time.local(1990, 8, 22), opening_price: 2560.15, high_price: 2630.69, low_price: 2553.22, close_price: 2560.15),
          have_attributes(date: Time.local(1990, 8, 23), opening_price: 2483.42, high_price: 2539.60, low_price: 2459.41, close_price: 2483.42),
          have_attributes(date: Time.local(1990, 8, 24), opening_price: 2532.92, high_price: 2555.69, low_price: 2480.45, close_price: 2532.92),
          have_attributes(date: Time.local(1990, 8, 27), opening_price: 2611.63, high_price: 2645.05, low_price: 2590.59, close_price: 2611.63),
          have_attributes(date: Time.local(1990, 8, 28), opening_price: 2614.85, high_price: 2629.95, low_price: 2582.92, close_price: 2614.85),
          have_attributes(date: Time.local(1990, 8, 29), opening_price: 2632.43, high_price: 2651.24, low_price: 2596.53, close_price: 2632.43),
          have_attributes(date: Time.local(1990, 8, 30), opening_price: 2593.32, high_price: 2641.34, low_price: 2578.47, close_price: 2593.32),
          have_attributes(date: Time.local(1990, 8, 31), opening_price: 2614.36, high_price: 2624.50, low_price: 2569.31, close_price: 2614.36),
          have_attributes(date: Time.local(1990, 9, 4), opening_price: 2613.37, high_price: 2618.07, low_price: 2573.02, close_price: 2613.37),
          have_attributes(date: Time.local(1990, 9, 5), opening_price: 2628.22, high_price: 2643.07, low_price: 2588.61, close_price: 2628.22),
          have_attributes(date: Time.local(1990, 9, 6), opening_price: 2596.29, high_price: 2633.17, low_price: 2575.99, close_price: 2596.29),
          have_attributes(date: Time.local(1990, 9, 7), opening_price: 2619.55, high_price: 2635.89, low_price: 2577.72, close_price: 2619.55),
          have_attributes(date: Time.local(1990, 9, 10), opening_price: 2615.59, high_price: 2665.35, low_price: 2600.99, close_price: 2615.59),
          have_attributes(date: Time.local(1990, 9, 11), opening_price: 2612.62, high_price: 2635.64, low_price: 2586.88, close_price: 2612.62),
          have_attributes(date: Time.local(1990, 9, 12), opening_price: 2625.74, high_price: 2639.11, low_price: 2592.33, close_price: 2625.74),
          have_attributes(date: Time.local(1990, 9, 13), opening_price: 2582.67, high_price: 2629.21, low_price: 2570.54, close_price: 2582.67),
          have_attributes(date: Time.local(1990, 9, 14), opening_price: 2564.11, high_price: 2585.15, low_price: 2545.54, close_price: 2564.11),
          have_attributes(date: Time.local(1990, 9, 17), opening_price: 2567.33, high_price: 2585.89, low_price: 2537.13, close_price: 2567.33),
          have_attributes(date: Time.local(1990, 9, 18), opening_price: 2571.29, high_price: 2587.87, low_price: 2524.26, close_price: 2571.29),
          have_attributes(date: Time.local(1990, 9, 19), opening_price: 2557.43, high_price: 2594.55, low_price: 2534.41, close_price: 2557.43),
          have_attributes(date: Time.local(1990, 9, 20), opening_price: 2518.32, high_price: 2549.01, low_price: 2495.54, close_price: 2518.32),
          have_attributes(date: Time.local(1990, 9, 21), opening_price: 2512.38, high_price: 2538.37, low_price: 2479.95, close_price: 2512.38),
          have_attributes(date: Time.local(1990, 9, 24), opening_price: 2452.97, high_price: 2498.02, low_price: 2438.12, close_price: 2452.97),
          have_attributes(date: Time.local(1990, 9, 25), opening_price: 2485.64, high_price: 2501.64, low_price: 2437.38, close_price: 2485.64),
          have_attributes(date: Time.local(1990, 9, 26), opening_price: 2459.65, high_price: 2496.04, low_price: 2435.40, close_price: 2459.65),
          have_attributes(date: Time.local(1990, 9, 27), opening_price: 2427.48, high_price: 2492.33, low_price: 2396.29, close_price: 2427.48),
          have_attributes(date: Time.local(1990, 9, 28), opening_price: 2452.48, high_price: 2465.59, low_price: 2367.82, close_price: 2452.48),
          have_attributes(date: Time.local(1990, 10, 1), opening_price: 2515.84, high_price: 2534.65, low_price: 2446.53, close_price: 2515.84),
          have_attributes(date: Time.local(1990, 10, 2), opening_price: 2505.20, high_price: 2565.35, low_price: 2487.62, close_price: 2505.20),
          have_attributes(date: Time.local(1990, 10, 3), opening_price: 2489.36, high_price: 2534.65, low_price: 2470.79, close_price: 2489.36),
          have_attributes(date: Time.local(1990, 10, 4), opening_price: 2516.83, high_price: 2528.22, low_price: 2464.85, close_price: 2516.83),
          have_attributes(date: Time.local(1990, 10, 5), opening_price: 2510.64, high_price: 2544.55, low_price: 2453.47, close_price: 2510.64),
          have_attributes(date: Time.local(1990, 10, 8), opening_price: 2523.76, high_price: 2548.02, low_price: 2507.18, close_price: 2523.76),
          have_attributes(date: Time.local(1990, 10, 9), opening_price: 2445.54, high_price: 2514.60, low_price: 2437.87, close_price: 2445.54),
          have_attributes(date: Time.local(1990, 10, 10), opening_price: 2407.92, high_price: 2472.03, low_price: 2387.38, close_price: 2407.92),
          have_attributes(date: Time.local(1990, 10, 11), opening_price: 2365.10, high_price: 2427.23, low_price: 2344.31, close_price: 2365.10),
          have_attributes(date: Time.local(1990, 10, 12), opening_price: 2398.02, high_price: 2428.71, low_price: 2349.75, close_price: 2398.02),
          have_attributes(date: Time.local(1990, 10, 15), opening_price: 2416.34, high_price: 2451.24, low_price: 2354.95, close_price: 2416.34),
          have_attributes(date: Time.local(1990, 10, 16), opening_price: 2381.19, high_price: 2432.41, low_price: 2366.83, close_price: 2381.19),
          have_attributes(date: Time.local(1990, 10, 17), opening_price: 2387.87, high_price: 2418.56, low_price: 2358.17, close_price: 2387.87),
          have_attributes(date: Time.local(1990, 10, 18), opening_price: 2452.72, high_price: 2461.63, low_price: 2391.83, close_price: 2452.72),
          have_attributes(date: Time.local(1990, 10, 19), opening_price: 2520.79, high_price: 2536.88, low_price: 2453.47, close_price: 2520.79),
          have_attributes(date: Time.local(1990, 10, 22), opening_price: 2516.09, high_price: 2535.40, low_price: 2476.73, close_price: 2516.09),
          have_attributes(date: Time.local(1990, 10, 23), opening_price: 2494.06, high_price: 2527.97, low_price: 2480.20, close_price: 2494.06),
          have_attributes(date: Time.local(1990, 10, 24), opening_price: 2504.21, high_price: 2523.02, low_price: 2470.54, close_price: 2504.21),
          have_attributes(date: Time.local(1990, 10, 25), opening_price: 2484.16, high_price: 2525.99, low_price: 2464.11, close_price: 2484.16),
          have_attributes(date: Time.local(1990, 10, 26), opening_price: 2436.14, high_price: 2482.18, low_price: 2429.21, close_price: 2436.14),
          have_attributes(date: Time.local(1990, 10, 29), opening_price: 2430.20, high_price: 2470.30, low_price: 2407.67, close_price: 2430.20),
          have_attributes(date: Time.local(1990, 10, 30), opening_price: 2448.02, high_price: 2462.87, low_price: 2400.50, close_price: 2448.02),
          have_attributes(date: Time.local(1990, 10, 31), opening_price: 2442.33, high_price: 2475.99, low_price: 2419.55, close_price: 2442.33),
          have_attributes(date: Time.local(1990, 11, 1), opening_price: 2454.95, high_price: 2473.02, low_price: 2415.59, close_price: 2454.95),
          have_attributes(date: Time.local(1990, 11, 2), opening_price: 2490.84, high_price: 2501.73, low_price: 2447.28, close_price: 2490.84),
          have_attributes(date: Time.local(1990, 11, 5), opening_price: 2502.23, high_price: 2519.06, low_price: 2472.77, close_price: 2502.23),
          have_attributes(date: Time.local(1990, 11, 6), opening_price: 2485.15, high_price: 2516.83, low_price: 2471.53, close_price: 2485.15),
          have_attributes(date: Time.local(1990, 11, 7), opening_price: 2440.84, high_price: 2490.35, low_price: 2430.94, close_price: 2440.84),
          have_attributes(date: Time.local(1990, 11, 8), opening_price: 2443.81, high_price: 2468.81, low_price: 2415.84, close_price: 2443.81),
          have_attributes(date: Time.local(1990, 11, 9), opening_price: 2488.61, high_price: 2500.74, low_price: 2438.61, close_price: 2488.61),
          have_attributes(date: Time.local(1990, 11, 12), opening_price: 2540.35, high_price: 2550.99, low_price: 2490.10, close_price: 2540.35),
          have_attributes(date: Time.local(1990, 11, 13), opening_price: 2535.40, high_price: 2559.90, low_price: 2512.38, close_price: 2535.40),
          have_attributes(date: Time.local(1990, 11, 14), opening_price: 2559.65, high_price: 2581.19, low_price: 2522.77, close_price: 2559.65),
          have_attributes(date: Time.local(1990, 11, 15), opening_price: 2545.05, high_price: 2567.33, low_price: 2528.71, close_price: 2545.05),
          have_attributes(date: Time.local(1990, 11, 16), opening_price: 2550.25, high_price: 2570.79, low_price: 2522.28, close_price: 2550.25),
          have_attributes(date: Time.local(1990, 11, 19), opening_price: 2565.35, high_price: 2580.69, low_price: 2543.07, close_price: 2565.35),
          have_attributes(date: Time.local(1990, 11, 20), opening_price: 2530.20, high_price: 2574.50, low_price: 2524.01, close_price: 2530.20),
          have_attributes(date: Time.local(1990, 11, 21), opening_price: 2539.36, high_price: 2552.23, low_price: 2502.72, close_price: 2539.36),
          have_attributes(date: Time.local(1990, 11, 23), opening_price: 2527.23, high_price: 2557.92, low_price: 2521.04, close_price: 2527.23),
          have_attributes(date: Time.local(1990, 11, 26), opening_price: 2533.17, high_price: 2541.58, low_price: 2489.85, close_price: 2533.17),
          have_attributes(date: Time.local(1990, 11, 27), opening_price: 2543.81, high_price: 2562.62, low_price: 2516.09, close_price: 2543.81),
          have_attributes(date: Time.local(1990, 11, 28), opening_price: 2535.15, high_price: 2564.60, low_price: 2521.04, close_price: 2535.15),
          have_attributes(date: Time.local(1990, 11, 29), opening_price: 2518.81, high_price: 2544.31, low_price: 2501.24, close_price: 2518.81),
          have_attributes(date: Time.local(1990, 11, 30), opening_price: 2559.65, high_price: 2577.23, low_price: 2498.51, close_price: 2559.65),
          have_attributes(date: Time.local(1990, 12, 3), opening_price: 2565.59, high_price: 2589.60, low_price: 2543.56, close_price: 2565.59),
          have_attributes(date: Time.local(1990, 12, 4), opening_price: 2579.70, high_price: 2592.08, low_price: 2534.65, close_price: 2579.70),
          have_attributes(date: Time.local(1990, 12, 5), opening_price: 2610.40, high_price: 2615.84, low_price: 2558.42, close_price: 2610.40),
          have_attributes(date: Time.local(1990, 12, 6), opening_price: 2602.48, high_price: 2656.44, low_price: 2589.36, close_price: 2602.48),
          have_attributes(date: Time.local(1990, 12, 7), opening_price: 2590.10, high_price: 2618.07, low_price: 2571.78, close_price: 2590.10),
          have_attributes(date: Time.local(1990, 12, 10), opening_price: 2596.78, high_price: 2609.41, low_price: 2566.58, close_price: 2596.78),
          have_attributes(date: Time.local(1990, 12, 11), opening_price: 2586.14, high_price: 2606.93, low_price: 2565.59, close_price: 2586.14),
          have_attributes(date: Time.local(1990, 12, 12), opening_price: 2622.28, high_price: 2630.69, low_price: 2578.22, close_price: 2622.28),
          have_attributes(date: Time.local(1990, 12, 13), opening_price: 2614.36, high_price: 2640.59, low_price: 2598.76, close_price: 2614.36),
          have_attributes(date: Time.local(1990, 12, 14), opening_price: 2593.81, high_price: 2617.82, low_price: 2572.03, close_price: 2593.81),
          have_attributes(date: Time.local(1990, 12, 17), opening_price: 2593.32, high_price: 2600.74, low_price: 2563.61, close_price: 2593.32),
          have_attributes(date: Time.local(1990, 12, 18), opening_price: 2626.73, high_price: 2639.36, low_price: 2583.17, close_price: 2626.73),
          have_attributes(date: Time.local(1990, 12, 19), opening_price: 2626.73, high_price: 2648.51, low_price: 2602.48, close_price: 2626.73),
          have_attributes(date: Time.local(1990, 12, 20), opening_price: 2629.46, high_price: 2648.51, low_price: 2591.58, close_price: 2629.46),
          have_attributes(date: Time.local(1990, 12, 21), opening_price: 2633.66, high_price: 2662.62, low_price: 2619.55, close_price: 2633.66),
          have_attributes(date: Time.local(1990, 12, 24), opening_price: 2621.29, high_price: 2638.12, low_price: 2609.65, close_price: 2621.29),
          have_attributes(date: Time.local(1990, 12, 26), opening_price: 2637.13, high_price: 2643.32, low_price: 2621.29, close_price: 2637.13),
          have_attributes(date: Time.local(1990, 12, 27), opening_price: 2625.50, high_price: 2652.23, low_price: 2616.58, close_price: 2625.50),
          have_attributes(date: Time.local(1990, 12, 28), opening_price: 2629.21, high_price: 2639.11, low_price: 2607.92, close_price: 2629.21),
          have_attributes(date: Time.local(1990, 12, 31), opening_price: 2633.66, high_price: 2641.09, low_price: 2611.14, close_price: 2633.66),
        ])
      end
    end

    context "2019s" do
      it "is prices" do
        context = {}

        @parser_2019.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::Djia.all).to match_array([
          have_attributes(date: Time.local(2019, 4, 4), opening_price: 26213.42, high_price: 26398.90, low_price: 26212.78, close_price: 26384.63),
          have_attributes(date: Time.local(2019, 4, 3), opening_price: 26238.03, high_price: 26282.17, low_price: 26138.47, close_price: 26218.13),
          have_attributes(date: Time.local(2019, 4, 2), opening_price: 26213.55, high_price: 26221.24, low_price: 26122.31, close_price: 26179.13),
          have_attributes(date: Time.local(2019, 4, 1), opening_price: 26075.10, high_price: 26280.90, low_price: 26071.69, close_price: 26258.42),
          have_attributes(date: Time.local(2019, 3, 29), opening_price: 25827.31, high_price: 25949.32, low_price: 25771.67, close_price: 25928.68),
          have_attributes(date: Time.local(2019, 3, 28), opening_price: 25693.32, high_price: 25743.41, low_price: 25576.69, close_price: 25717.46),
          have_attributes(date: Time.local(2019, 3, 27), opening_price: 25676.34, high_price: 25758.17, low_price: 25425.27, close_price: 25625.59),
          have_attributes(date: Time.local(2019, 3, 26), opening_price: 25649.56, high_price: 25796.29, low_price: 25544.78, close_price: 25657.73),
          have_attributes(date: Time.local(2019, 3, 25), opening_price: 25490.72, high_price: 25603.27, low_price: 25372.26, close_price: 25516.83),
          have_attributes(date: Time.local(2019, 3, 22), opening_price: 25844.65, high_price: 25877.01, low_price: 25501.45, close_price: 25502.32),
          have_attributes(date: Time.local(2019, 3, 21), opening_price: 25688.44, high_price: 26009.90, low_price: 25657.78, close_price: 25962.51),
          have_attributes(date: Time.local(2019, 3, 20), opening_price: 25867.79, high_price: 25929.52, low_price: 25670.63, close_price: 25745.67),
          have_attributes(date: Time.local(2019, 3, 19), opening_price: 25987.87, high_price: 26109.68, low_price: 25814.92, close_price: 25887.38),
          have_attributes(date: Time.local(2019, 3, 18), opening_price: 25801.88, high_price: 25924.77, low_price: 25785.66, close_price: 25914.10),
          have_attributes(date: Time.local(2019, 3, 15), opening_price: 25720.96, high_price: 25927.91, low_price: 25649.70, close_price: 25848.87),
          have_attributes(date: Time.local(2019, 3, 14), opening_price: 25692.31, high_price: 25752.84, low_price: 25621.31, close_price: 25709.94),
          have_attributes(date: Time.local(2019, 3, 13), opening_price: 25637.23, high_price: 25776.49, low_price: 25571.31, close_price: 25702.89),
          have_attributes(date: Time.local(2019, 3, 12), opening_price: 25600.30, high_price: 25675.44, low_price: 25522.17, close_price: 25554.66),
          have_attributes(date: Time.local(2019, 3, 11), opening_price: 25208.00, high_price: 25661.63, low_price: 25208.00, close_price: 25650.88),
          have_attributes(date: Time.local(2019, 3, 8), opening_price: 25347.38, high_price: 25466.14, low_price: 25252.46, close_price: 25450.24),
          have_attributes(date: Time.local(2019, 3, 7), opening_price: 25645.45, high_price: 25645.45, low_price: 25352.55, close_price: 25473.23),
          have_attributes(date: Time.local(2019, 3, 6), opening_price: 25818.76, high_price: 25837.61, low_price: 25633.71, close_price: 25673.46),
          have_attributes(date: Time.local(2019, 3, 5), opening_price: 25829.07, high_price: 25877.15, low_price: 25725.63, close_price: 25806.63),
          have_attributes(date: Time.local(2019, 3, 4), opening_price: 26122.19, high_price: 26155.98, low_price: 25611.55, close_price: 25819.65),
          have_attributes(date: Time.local(2019, 3, 1), opening_price: 26019.67, high_price: 26143.92, low_price: 25914.37, close_price: 26026.32),
          have_attributes(date: Time.local(2019, 2, 28), opening_price: 25984.28, high_price: 26029.21, low_price: 25896.56, close_price: 25916.00),
          have_attributes(date: Time.local(2019, 2, 27), opening_price: 25995.60, high_price: 26039.68, low_price: 25877.24, close_price: 25985.16),
          have_attributes(date: Time.local(2019, 2, 26), opening_price: 26051.61, high_price: 26155.29, low_price: 25966.01, close_price: 26057.98),
          have_attributes(date: Time.local(2019, 2, 25), opening_price: 26126.15, high_price: 26241.42, low_price: 26080.66, close_price: 26091.95),
          have_attributes(date: Time.local(2019, 2, 22), opening_price: 25906.27, high_price: 26052.90, low_price: 25906.27, close_price: 26031.81),
          have_attributes(date: Time.local(2019, 2, 21), opening_price: 25922.41, high_price: 25938.88, low_price: 25762.21, close_price: 25850.63),
          have_attributes(date: Time.local(2019, 2, 20), opening_price: 25872.26, high_price: 25986.20, low_price: 25846.48, close_price: 25954.44),
          have_attributes(date: Time.local(2019, 2, 19), opening_price: 25849.85, high_price: 25961.44, low_price: 25820.01, close_price: 25891.32),
          have_attributes(date: Time.local(2019, 2, 15), opening_price: 25564.63, high_price: 25883.72, low_price: 25564.63, close_price: 25883.25),
          have_attributes(date: Time.local(2019, 2, 14), opening_price: 25460.65, high_price: 25558.90, low_price: 25308.09, close_price: 25439.39),
          have_attributes(date: Time.local(2019, 2, 13), opening_price: 25480.86, high_price: 25625.95, low_price: 25480.86, close_price: 25543.27),
          have_attributes(date: Time.local(2019, 2, 12), opening_price: 25152.03, high_price: 25458.98, low_price: 25152.03, close_price: 25425.76),
          have_attributes(date: Time.local(2019, 2, 11), opening_price: 25142.81, high_price: 25196.75, low_price: 25009.10, close_price: 25053.11),
          have_attributes(date: Time.local(2019, 2, 8), opening_price: 25042.36, high_price: 25106.39, low_price: 24883.04, close_price: 25106.33),
          have_attributes(date: Time.local(2019, 2, 7), opening_price: 25265.81, high_price: 25314.26, low_price: 25000.52, close_price: 25169.53),
          have_attributes(date: Time.local(2019, 2, 6), opening_price: 25371.57, high_price: 25439.04, low_price: 25312.06, close_price: 25390.30),
          have_attributes(date: Time.local(2019, 2, 5), opening_price: 25287.93, high_price: 25427.32, low_price: 25287.65, close_price: 25411.52),
          have_attributes(date: Time.local(2019, 2, 4), opening_price: 25062.12, high_price: 25239.91, low_price: 24977.67, close_price: 25239.37),
          have_attributes(date: Time.local(2019, 2, 1), opening_price: 25025.31, high_price: 25193.15, low_price: 24982.49, close_price: 25063.89),
          have_attributes(date: Time.local(2019, 1, 31), opening_price: 24954.48, high_price: 25049.62, low_price: 24842.09, close_price: 24999.67),
          have_attributes(date: Time.local(2019, 1, 30), opening_price: 24826.52, high_price: 25109.62, low_price: 24790.90, close_price: 25014.86),
          have_attributes(date: Time.local(2019, 1, 29), opening_price: 24519.62, high_price: 24674.87, low_price: 24504.04, close_price: 24579.96),
          have_attributes(date: Time.local(2019, 1, 28), opening_price: 24596.98, high_price: 24596.98, low_price: 24323.94, close_price: 24528.22),
          have_attributes(date: Time.local(2019, 1, 25), opening_price: 24687.21, high_price: 24860.15, low_price: 24676.75, close_price: 24737.20),
          have_attributes(date: Time.local(2019, 1, 24), opening_price: 24579.96, high_price: 24626.30, low_price: 24422.73, close_price: 24553.24),
          have_attributes(date: Time.local(2019, 1, 23), opening_price: 24577.25, high_price: 24700.98, low_price: 24307.17, close_price: 24575.62),
          have_attributes(date: Time.local(2019, 1, 22), opening_price: 24607.76, high_price: 24607.76, low_price: 24244.31, close_price: 24404.48),
          have_attributes(date: Time.local(2019, 1, 18), opening_price: 24534.19, high_price: 24750.22, low_price: 24459.03, close_price: 24706.35),
          have_attributes(date: Time.local(2019, 1, 17), opening_price: 24147.09, high_price: 24474.46, low_price: 24088.90, close_price: 24370.10),
          have_attributes(date: Time.local(2019, 1, 16), opening_price: 24139.91, high_price: 24288.61, low_price: 24119.72, close_price: 24207.16),
          have_attributes(date: Time.local(2019, 1, 15), opening_price: 23914.11, high_price: 24099.14, low_price: 23887.93, close_price: 24065.59),
          have_attributes(date: Time.local(2019, 1, 14), opening_price: 23880.53, high_price: 23964.90, low_price: 23765.24, close_price: 23909.84),
          have_attributes(date: Time.local(2019, 1, 11), opening_price: 23940.01, high_price: 23996.32, low_price: 23798.16, close_price: 23995.95),
          have_attributes(date: Time.local(2019, 1, 10), opening_price: 23811.11, high_price: 24014.78, low_price: 23703.25, close_price: 24001.92),
          have_attributes(date: Time.local(2019, 1, 9), opening_price: 23844.27, high_price: 23985.45, low_price: 23776.56, close_price: 23879.12),
          have_attributes(date: Time.local(2019, 1, 8), opening_price: 23680.32, high_price: 23864.65, low_price: 23581.45, close_price: 23787.45),
          have_attributes(date: Time.local(2019, 1, 7), opening_price: 23474.26, high_price: 23687.74, low_price: 23301.59, close_price: 23531.35),
          have_attributes(date: Time.local(2019, 1, 4), opening_price: 22894.92, high_price: 23518.64, low_price: 22894.92, close_price: 23433.16),
          have_attributes(date: Time.local(2019, 1, 3), opening_price: 23176.39, high_price: 23176.39, low_price: 22638.41, close_price: 22686.22),
          have_attributes(date: Time.local(2019, 1, 2), opening_price: 23058.61, high_price: 23413.47, low_price: 22928.59, close_price: 23346.24),
        ])
      end
    end
  end
end

