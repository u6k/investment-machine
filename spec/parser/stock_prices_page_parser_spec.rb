require "timecop"
require "webmock/rspec"

RSpec.describe InvestmentMachine::Parser::StockPricesPageParser do
  before do
    # Setup database
    InvestmentMachine::Model::Company.delete_all
    InvestmentMachine::Model::StockPrice.delete_all

    # Setup parser
    @downloader = Crawline::Downloader.new("investment-machine/#{InvestmentMachine::VERSION}")

    WebMock.enable!

    @url = "https://kabuoji3.com/stock/1301/"
    WebMock.stub_request(:get, @url).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_prices_page.1301.html").read)

    Timecop.freeze(Time.utc(2019, 3, 24, 3, 11, 23)) do
      @parser = InvestmentMachine::Parser::StockPricesPageParser.new(@url, @downloader.download_with_get(@url))
    end

    @url_error = "https://kabuoji3.com/stock/1301/9999/"
    WebMock.stub_request(:get, @url_error).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_prices_page.error.html").read)

    @parser_error = InvestmentMachine::Parser::StockPricesPageParser.new(@url_error, @downloader.download_with_get(@url_error))

    WebMock.disable!
  end

  describe "#redownload?" do
    it "redownload if newer than 1 year" do
      Timecop.freeze(Time.local(2020, 3, 20)) do
        expect(@parser).to be_redownload
      end
    end

    it "do not redownload if over 1 year old" do
      Timecop.freeze(Time.local(2020, 3, 21)) do
        expect(@parser).not_to be_redownload
      end
    end

    it "redownload if 23 hours has passed" do
      Timecop.freeze(Time.utc(2019, 3, 25, 2, 11, 23)) do
        expect(@parser).to be_redownload
      end
    end

    it "do not redownload within 23 hours" do
      Timecop.freeze(Time.utc(2019, 3, 25, 2, 11, 22)) do
        expect(@parser).not_to be_redownload
      end
    end
  end

  describe "#valid?" do
    context "valid page" do
      it "is valid" do
        expect(@parser).to be_valid
      end
    end

    context "error page" do
      it "is invalid" do
        expect(@parser_error).not_to be_valid
      end
    end

    context "valid page on web" do
      it "is valid" do
        data = @downloader.download_with_get(@url)
        parser = InvestmentMachine::Parser::StockPricesPageParser.new(@url, @downloader.download_with_get(@url))

        expect(parser).to be_valid
      end
    end
  end

  describe "#related_links" do
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

  describe "#parse" do
    it "is company info, and stock prices" do
      @parser.parse({})

      expect(InvestmentMachine::Model::Company.all).to match_array([
        have_attributes(ticker_symbol: "1301",
                        name: "(株)極洋",
                        market: "東証1部")
      ])

      expect(InvestmentMachine::Model::StockPrice.all).to match_array([
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 22), opening_price: 3040, high_price: 3045, low_price: 3000, close_price: 3015, turnover: 43400, adjustment_value: 3015),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 20), opening_price: 3010, high_price: 3035, low_price: 2997, close_price: 3035, turnover: 25900, adjustment_value: 3035),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 19), opening_price: 3050, high_price: 3055, low_price: 2991, close_price: 2994, turnover: 59800, adjustment_value: 2994),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 18), opening_price: 3030, high_price: 3050, low_price: 3000, close_price: 3050, turnover: 36500, adjustment_value: 3050),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 15), opening_price: 3010, high_price: 3040, low_price: 2993, close_price: 2996, turnover: 44200, adjustment_value: 2996),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 14), opening_price: 3030, high_price: 3030, low_price: 3000, close_price: 3010, turnover: 13200, adjustment_value: 3010),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 13), opening_price: 3015, high_price: 3030, low_price: 3005, close_price: 3015, turnover: 16700, adjustment_value: 3015),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 12), opening_price: 2986, high_price: 3020, low_price: 2978, close_price: 3015, turnover: 19800, adjustment_value: 3015),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3, 11), opening_price: 2943, high_price: 2963, low_price: 2930, close_price: 2959, turnover: 21700, adjustment_value: 2959),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3,  8), opening_price: 2975, high_price: 2975, low_price: 2906, close_price: 2924, turnover: 51100, adjustment_value: 2924),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3,  7), opening_price: 3005, high_price: 3015, low_price: 2998, close_price: 3000, turnover: 25800, adjustment_value: 3000),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3,  6), opening_price: 3020, high_price: 3025, low_price: 3005, close_price: 3005, turnover: 18100, adjustment_value: 3005),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3,  5), opening_price: 3005, high_price: 3030, low_price: 3005, close_price: 3020, turnover: 10100, adjustment_value: 3020),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3,  4), opening_price: 3020, high_price: 3035, low_price: 2997, close_price: 3010, turnover: 22300, adjustment_value: 3010),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  3,  1), opening_price: 2998, high_price: 3020, low_price: 2998, close_price: 3000, turnover: 17000, adjustment_value: 3000),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 28), opening_price: 2990, high_price: 3030, low_price: 2985, close_price: 3005, turnover: 28000, adjustment_value: 3005),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 27), opening_price: 2984, high_price: 3005, low_price: 2972, close_price: 2990, turnover: 26900, adjustment_value: 2990),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 26), opening_price: 2985, high_price: 3000, low_price: 2966, close_price: 2975, turnover: 17100, adjustment_value: 2975),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 25), opening_price: 2993, high_price: 2995, low_price: 2966, close_price: 2982, turnover: 20700, adjustment_value: 2982),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 22), opening_price: 2990, high_price: 3015, low_price: 2975, close_price: 2993, turnover: 16800, adjustment_value: 2993),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 21), opening_price: 2988, high_price: 3010, low_price: 2977, close_price: 2998, turnover: 14000, adjustment_value: 2998),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 20), opening_price: 2980, high_price: 2998, low_price: 2969, close_price: 2990, turnover: 17900, adjustment_value: 2990),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 19), opening_price: 2964, high_price: 2977, low_price: 2964, close_price: 2972, turnover: 10100, adjustment_value: 2972),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 18), opening_price: 2940, high_price: 2978, low_price: 2940, close_price: 2963, turnover: 23200, adjustment_value: 2963),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 15), opening_price: 2921, high_price: 2941, low_price: 2900, close_price: 2935, turnover: 28000, adjustment_value: 2935),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 14), opening_price: 2915, high_price: 2941, low_price: 2911, close_price: 2918, turnover: 16900, adjustment_value: 2918),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 13), opening_price: 2910, high_price: 2917, low_price: 2871, close_price: 2909, turnover: 21900, adjustment_value: 2909),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2, 12), opening_price: 2831, high_price: 2909, low_price: 2831, close_price: 2907, turnover: 35600, adjustment_value: 2907),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2,  8), opening_price: 2816, high_price: 2856, low_price: 2788, close_price: 2814, turnover: 42400, adjustment_value: 2814),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2,  7), opening_price: 2815, high_price: 2830, low_price: 2802, close_price: 2816, turnover: 15500, adjustment_value: 2816),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2,  6), opening_price: 2862, high_price: 2862, low_price: 2825, close_price: 2841, turnover: 16700, adjustment_value: 2841),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2,  5), opening_price: 2802, high_price: 2848, low_price: 2802, close_price: 2836, turnover: 24800, adjustment_value: 2836),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2,  4), opening_price: 2744, high_price: 2801, low_price: 2744, close_price: 2799, turnover: 24000, adjustment_value: 2799),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  2,  1), opening_price: 2752, high_price: 2752, low_price: 2727, close_price: 2729, turnover: 28100, adjustment_value: 2729),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 31), opening_price: 2755, high_price: 2778, low_price: 2749, close_price: 2752, turnover: 29900, adjustment_value: 2752),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 30), opening_price: 2789, high_price: 2789, low_price: 2750, close_price: 2750, turnover: 29600, adjustment_value: 2750),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 29), opening_price: 2792, high_price: 2793, low_price: 2768, close_price: 2782, turnover: 28500, adjustment_value: 2782),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 28), opening_price: 2825, high_price: 2825, low_price: 2790, close_price: 2792, turnover: 31100, adjustment_value: 2792),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 25), opening_price: 2850, high_price: 2865, low_price: 2821, close_price: 2828, turnover: 19100, adjustment_value: 2828),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 24), opening_price: 2837, high_price: 2857, low_price: 2811, close_price: 2841, turnover: 13100, adjustment_value: 2841),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 23), opening_price: 2830, high_price: 2843, low_price: 2816, close_price: 2837, turnover: 16100, adjustment_value: 2837),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 22), opening_price: 2865, high_price: 2868, low_price: 2836, close_price: 2853, turnover: 18200, adjustment_value: 2853),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 21), opening_price: 2864, high_price: 2879, low_price: 2838, close_price: 2847, turnover: 22500, adjustment_value: 2847),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 18), opening_price: 2828, high_price: 2855, low_price: 2818, close_price: 2836, turnover: 21300, adjustment_value: 2836),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 17), opening_price: 2828, high_price: 2846, low_price: 2808, close_price: 2828, turnover: 14800, adjustment_value: 2828),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 16), opening_price: 2838, high_price: 2868, low_price: 2826, close_price: 2826, turnover: 17700, adjustment_value: 2826),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 15), opening_price: 2865, high_price: 2866, low_price: 2844, close_price: 2849, turnover: 19400, adjustment_value: 2849),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 11), opening_price: 2893, high_price: 2906, low_price: 2850, close_price: 2862, turnover: 20500, adjustment_value: 2862),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1, 10), opening_price: 2910, high_price: 2933, low_price: 2875, close_price: 2901, turnover: 14200, adjustment_value: 2901),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1,  9), opening_price: 2900, high_price: 2942, low_price: 2898, close_price: 2919, turnover: 15800, adjustment_value: 2919),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1,  8), opening_price: 2866, high_price: 2901, low_price: 2861, close_price: 2867, turnover: 19900, adjustment_value: 2867),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1,  7), opening_price: 2890, high_price: 2937, low_price: 2843, close_price: 2859, turnover: 35400, adjustment_value: 2859),
        have_attributes(ticker_symbol: "1301", date: Time.local(2019,  1,  4), opening_price: 2806, high_price: 2861, low_price: 2760, close_price: 2852, turnover: 26200, adjustment_value: 2852),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 28), opening_price: 2874, high_price: 2908, low_price: 2840, close_price: 2882, turnover: 24400, adjustment_value: 2882),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 27), opening_price: 2820, high_price: 2893, low_price: 2784, close_price: 2874, turnover: 33300, adjustment_value: 2874),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 26), opening_price: 2630, high_price: 2753, low_price: 2630, close_price: 2699, turnover: 30400, adjustment_value: 2699),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 25), opening_price: 2624, high_price: 2650, low_price: 2581, close_price: 2607, turnover: 54900, adjustment_value: 2607),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 21), opening_price: 2852, high_price: 2852, low_price: 2741, close_price: 2745, turnover: 55600, adjustment_value: 2745),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 20), opening_price: 2940, high_price: 2950, low_price: 2853, close_price: 2872, turnover: 33400, adjustment_value: 2872),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 19), opening_price: 2972, high_price: 2986, low_price: 2943, close_price: 2963, turnover: 19800, adjustment_value: 2963),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 18), opening_price: 3005, high_price: 3010, low_price: 2975, close_price: 2975, turnover: 32400, adjustment_value: 2975),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 17), opening_price: 3035, high_price: 3040, low_price: 3020, close_price: 3030, turnover: 14400, adjustment_value: 3030),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 14), opening_price: 3085, high_price: 3110, low_price: 3050, close_price: 3055, turnover: 21400, adjustment_value: 3055),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 13), opening_price: 3080, high_price: 3090, low_price: 3055, close_price: 3085, turnover: 21400, adjustment_value: 3085),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 12), opening_price: 3035, high_price: 3080, low_price: 3035, close_price: 3055, turnover: 13400, adjustment_value: 3055),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 11), opening_price: 3110, high_price: 3115, low_price: 3030, close_price: 3030, turnover: 21400, adjustment_value: 3030),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12, 10), opening_price: 3185, high_price: 3185, low_price: 3105, close_price: 3105, turnover: 20500, adjustment_value: 3105),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12,  7), opening_price: 3230, high_price: 3235, low_price: 3165, close_price: 3225, turnover: 20700, adjustment_value: 3225),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12,  6), opening_price: 3195, high_price: 3200, low_price: 3170, close_price: 3180, turnover: 19800, adjustment_value: 3180),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12,  5), opening_price: 3190, high_price: 3240, low_price: 3165, close_price: 3235, turnover: 20800, adjustment_value: 3235),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12,  4), opening_price: 3320, high_price: 3320, low_price: 3250, close_price: 3250, turnover: 30600, adjustment_value: 3250),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 12,  3), opening_price: 3225, high_price: 3335, low_price: 3225, close_price: 3320, turnover: 43300, adjustment_value: 3320),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 30), opening_price: 3245, high_price: 3245, low_price: 3195, close_price: 3225, turnover: 25700, adjustment_value: 3225),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 29), opening_price: 3185, high_price: 3250, low_price: 3185, close_price: 3215, turnover: 36100, adjustment_value: 3215),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 28), opening_price: 3165, high_price: 3170, low_price: 3130, close_price: 3155, turnover: 16400, adjustment_value: 3155),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 27), opening_price: 3110, high_price: 3165, low_price: 3110, close_price: 3150, turnover: 23900, adjustment_value: 3150),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 26), opening_price: 3060, high_price: 3105, low_price: 3055, close_price: 3100, turnover: 30300, adjustment_value: 3100),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 22), opening_price: 3035, high_price: 3070, low_price: 3010, close_price: 3065, turnover: 21200, adjustment_value: 3065),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 21), opening_price: 2989, high_price: 3050, low_price: 2987, close_price: 3040, turnover: 21800, adjustment_value: 3040),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 20), opening_price: 3035, high_price: 3100, low_price: 3020, close_price: 3075, turnover: 34300, adjustment_value: 3075),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 19), opening_price: 3010, high_price: 3035, low_price: 2983, close_price: 3030, turnover: 51500, adjustment_value: 3030),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 16), opening_price: 3025, high_price: 3025, low_price: 3005, close_price: 3010, turnover: 36500, adjustment_value: 3010),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 15), opening_price: 3005, high_price: 3025, low_price: 2995, close_price: 3015, turnover: 33900, adjustment_value: 3015),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 14), opening_price: 3050, high_price: 3060, low_price: 3000, close_price: 3010, turnover: 51200, adjustment_value: 3010),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 13), opening_price: 3090, high_price: 3100, low_price: 3030, close_price: 3040, turnover: 35700, adjustment_value: 3040),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11, 12), opening_price: 3065, high_price: 3175, low_price: 3065, close_price: 3160, turnover: 39400, adjustment_value: 3160),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11,  9), opening_price: 3055, high_price: 3100, low_price: 3045, close_price: 3055, turnover: 29300, adjustment_value: 3055),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11,  8), opening_price: 3060, high_price: 3085, low_price: 3050, close_price: 3065, turnover: 18300, adjustment_value: 3065),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11,  7), opening_price: 3045, high_price: 3080, low_price: 3010, close_price: 3020, turnover: 35000, adjustment_value: 3020),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11,  6), opening_price: 3015, high_price: 3115, low_price: 3010, close_price: 3045, turnover: 30700, adjustment_value: 3045),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11,  5), opening_price: 3100, high_price: 3100, low_price: 3015, close_price: 3025, turnover: 38500, adjustment_value: 3025),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11,  2), opening_price: 3100, high_price: 3130, low_price: 3055, close_price: 3110, turnover: 31900, adjustment_value: 3110),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 11,  1), opening_price: 3100, high_price: 3105, low_price: 3070, close_price: 3090, turnover: 16000, adjustment_value: 3090),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 31), opening_price: 3025, high_price: 3105, low_price: 3025, close_price: 3095, turnover: 26000, adjustment_value: 3095),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 30), opening_price: 2995, high_price: 3025, low_price: 2981, close_price: 3005, turnover: 27400, adjustment_value: 3005),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 29), opening_price: 3070, high_price: 3090, low_price: 2997, close_price: 2997, turnover: 32700, adjustment_value: 2997),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 26), opening_price: 3080, high_price: 3080, low_price: 3015, close_price: 3070, turnover: 33100, adjustment_value: 3070),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 25), opening_price: 3085, high_price: 3085, low_price: 3025, close_price: 3030, turnover: 39700, adjustment_value: 3030),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 24), opening_price: 3065, high_price: 3155, low_price: 3060, close_price: 3145, turnover: 23100, adjustment_value: 3145),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 23), opening_price: 3120, high_price: 3120, low_price: 3055, close_price: 3055, turnover: 38100, adjustment_value: 3055),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 22), opening_price: 3120, high_price: 3140, low_price: 3100, close_price: 3110, turnover: 24400, adjustment_value: 3110),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 19), opening_price: 3145, high_price: 3145, low_price: 3100, close_price: 3110, turnover: 24000, adjustment_value: 3110),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 18), opening_price: 3135, high_price: 3170, low_price: 3135, close_price: 3145, turnover: 12200, adjustment_value: 3145),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 17), opening_price: 3150, high_price: 3165, low_price: 3115, close_price: 3135, turnover: 23300, adjustment_value: 3135),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 16), opening_price: 3110, high_price: 3125, low_price: 3080, close_price: 3120, turnover: 19600, adjustment_value: 3120),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 15), opening_price: 3185, high_price: 3185, low_price: 3115, close_price: 3115, turnover: 22700, adjustment_value: 3115),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 12), opening_price: 3170, high_price: 3205, low_price: 3145, close_price: 3175, turnover: 25800, adjustment_value: 3175),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 11), opening_price: 3190, high_price: 3225, low_price: 3175, close_price: 3195, turnover: 28100, adjustment_value: 3195),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10, 10), opening_price: 3235, high_price: 3325, low_price: 3235, close_price: 3300, turnover: 13600, adjustment_value: 3300),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10,  9), opening_price: 3295, high_price: 3295, low_price: 3230, close_price: 3245, turnover: 15000, adjustment_value: 3245),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10,  5), opening_price: 3300, high_price: 3340, low_price: 3300, close_price: 3315, turnover: 12600, adjustment_value: 3315),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10,  4), opening_price: 3340, high_price: 3365, low_price: 3320, close_price: 3330, turnover:  9300, adjustment_value: 3330),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10,  3), opening_price: 3360, high_price: 3370, low_price: 3340, close_price: 3340, turnover: 14900, adjustment_value: 3340),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10,  2), opening_price: 3385, high_price: 3415, low_price: 3360, close_price: 3365, turnover: 12800, adjustment_value: 3365),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018, 10,  1), opening_price: 3415, high_price: 3445, low_price: 3380, close_price: 3380, turnover: 14000, adjustment_value: 3380),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 28), opening_price: 3440, high_price: 3445, low_price: 3395, close_price: 3400, turnover: 11800, adjustment_value: 3400),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 27), opening_price: 3445, high_price: 3500, low_price: 3390, close_price: 3395, turnover: 19500, adjustment_value: 3395),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 26), opening_price: 3420, high_price: 3495, low_price: 3410, close_price: 3485, turnover: 35000, adjustment_value: 3485),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 25), opening_price: 3300, high_price: 3385, low_price: 3300, close_price: 3385, turnover: 25600, adjustment_value: 3385),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 21), opening_price: 3340, high_price: 3340, low_price: 3265, close_price: 3310, turnover: 39400, adjustment_value: 3310),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 20), opening_price: 3350, high_price: 3350, low_price: 3300, close_price: 3320, turnover: 16700, adjustment_value: 3320),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 19), opening_price: 3330, high_price: 3350, low_price: 3295, close_price: 3330, turnover: 32700, adjustment_value: 3330),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 18), opening_price: 3185, high_price: 3280, low_price: 3180, close_price: 3280, turnover: 33700, adjustment_value: 3280),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 14), opening_price: 3190, high_price: 3195, low_price: 3165, close_price: 3185, turnover: 29500, adjustment_value: 3185),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 13), opening_price: 3105, high_price: 3160, low_price: 3100, close_price: 3140, turnover: 32100, adjustment_value: 3140),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 12), opening_price: 3105, high_price: 3110, low_price: 3070, close_price: 3095, turnover: 19600, adjustment_value: 3095),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 11), opening_price: 3125, high_price: 3130, low_price: 3075, close_price: 3095, turnover: 29000, adjustment_value: 3095),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9, 10), opening_price: 3120, high_price: 3150, low_price: 3095, close_price: 3130, turnover: 26100, adjustment_value: 3130),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9,  7), opening_price: 3120, high_price: 3145, low_price: 3085, close_price: 3115, turnover: 30900, adjustment_value: 3115),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9,  6), opening_price: 3195, high_price: 3195, low_price: 3115, close_price: 3120, turnover: 30000, adjustment_value: 3120),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9,  5), opening_price: 3180, high_price: 3215, low_price: 3180, close_price: 3215, turnover: 14300, adjustment_value: 3215),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9,  4), opening_price: 3130, high_price: 3240, low_price: 3120, close_price: 3200, turnover: 35700, adjustment_value: 3200),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  9,  3), opening_price: 3150, high_price: 3150, low_price: 3100, close_price: 3115, turnover: 31700, adjustment_value: 3115),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 31), opening_price: 3210, high_price: 3210, low_price: 3140, close_price: 3145, turnover: 48400, adjustment_value: 3145),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 30), opening_price: 3240, high_price: 3255, low_price: 3195, close_price: 3195, turnover: 29900, adjustment_value: 3195),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 29), opening_price: 3225, high_price: 3235, low_price: 3215, close_price: 3220, turnover: 16700, adjustment_value: 3220),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 28), opening_price: 3240, high_price: 3260, low_price: 3225, close_price: 3225, turnover: 17800, adjustment_value: 3225),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 27), opening_price: 3260, high_price: 3260, low_price: 3215, close_price: 3225, turnover: 33200, adjustment_value: 3225),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 24), opening_price: 3250, high_price: 3265, low_price: 3250, close_price: 3260, turnover:  6800, adjustment_value: 3260),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 23), opening_price: 3280, high_price: 3280, low_price: 3250, close_price: 3250, turnover: 10400, adjustment_value: 3250),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 22), opening_price: 3245, high_price: 3295, low_price: 3245, close_price: 3290, turnover: 12400, adjustment_value: 3290),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 21), opening_price: 3230, high_price: 3265, low_price: 3220, close_price: 3245, turnover: 15700, adjustment_value: 3245),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 20), opening_price: 3290, high_price: 3290, low_price: 3250, close_price: 3255, turnover: 13800, adjustment_value: 3255),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 17), opening_price: 3240, high_price: 3275, low_price: 3235, close_price: 3270, turnover: 11000, adjustment_value: 3270),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 16), opening_price: 3270, high_price: 3270, low_price: 3210, close_price: 3255, turnover: 17000, adjustment_value: 3255),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 15), opening_price: 3295, high_price: 3315, low_price: 3255, close_price: 3275, turnover:  8100, adjustment_value: 3275),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 14), opening_price: 3270, high_price: 3320, low_price: 3265, close_price: 3295, turnover: 12800, adjustment_value: 3295),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 13), opening_price: 3290, high_price: 3305, low_price: 3225, close_price: 3240, turnover: 29600, adjustment_value: 3240),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8, 10), opening_price: 3325, high_price: 3325, low_price: 3275, close_price: 3290, turnover: 20500, adjustment_value: 3290),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8,  9), opening_price: 3300, high_price: 3310, low_price: 3275, close_price: 3300, turnover: 15000, adjustment_value: 3300),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8,  8), opening_price: 3370, high_price: 3395, low_price: 3305, close_price: 3315, turnover: 24700, adjustment_value: 3315),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8,  7), opening_price: 3305, high_price: 3410, low_price: 3270, close_price: 3405, turnover: 33300, adjustment_value: 3405),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8,  6), opening_price: 3215, high_price: 3300, low_price: 3215, close_price: 3265, turnover: 22800, adjustment_value: 3265),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8,  3), opening_price: 3420, high_price: 3445, low_price: 3215, close_price: 3260, turnover: 61700, adjustment_value: 3260),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8,  2), opening_price: 3470, high_price: 3485, low_price: 3435, close_price: 3435, turnover: 13500, adjustment_value: 3435),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  8,  1), opening_price: 3575, high_price: 3575, low_price: 3450, close_price: 3470, turnover: 22800, adjustment_value: 3470),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 31), opening_price: 3530, high_price: 3560, low_price: 3475, close_price: 3480, turnover: 33600, adjustment_value: 3480),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 30), opening_price: 3570, high_price: 3575, low_price: 3550, close_price: 3570, turnover: 10300, adjustment_value: 3570),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 27), opening_price: 3615, high_price: 3615, low_price: 3580, close_price: 3585, turnover: 10500, adjustment_value: 3585),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 26), opening_price: 3570, high_price: 3620, low_price: 3570, close_price: 3590, turnover: 11500, adjustment_value: 3590),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 25), opening_price: 3570, high_price: 3590, low_price: 3565, close_price: 3570, turnover: 11500, adjustment_value: 3570),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 24), opening_price: 3515, high_price: 3615, low_price: 3515, close_price: 3565, turnover: 19500, adjustment_value: 3565),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 23), opening_price: 3550, high_price: 3575, low_price: 3515, close_price: 3530, turnover: 26200, adjustment_value: 3530),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 20), opening_price: 3545, high_price: 3560, low_price: 3500, close_price: 3535, turnover: 13600, adjustment_value: 3535),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 19), opening_price: 3500, high_price: 3530, low_price: 3495, close_price: 3505, turnover: 10100, adjustment_value: 3505),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 18), opening_price: 3515, high_price: 3525, low_price: 3500, close_price: 3505, turnover:  7800, adjustment_value: 3505),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 17), opening_price: 3445, high_price: 3525, low_price: 3440, close_price: 3485, turnover: 18900, adjustment_value: 3485),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 13), opening_price: 3430, high_price: 3460, low_price: 3405, close_price: 3460, turnover: 13500, adjustment_value: 3460),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 12), opening_price: 3370, high_price: 3415, low_price: 3365, close_price: 3400, turnover: 12500, adjustment_value: 3400),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 11), opening_price: 3405, high_price: 3420, low_price: 3380, close_price: 3380, turnover: 20300, adjustment_value: 3380),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7, 10), opening_price: 3490, high_price: 3490, low_price: 3405, close_price: 3405, turnover: 24600, adjustment_value: 3405),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7,  9), opening_price: 3470, high_price: 3485, low_price: 3445, close_price: 3480, turnover: 20500, adjustment_value: 3480),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7,  6), opening_price: 3465, high_price: 3475, low_price: 3405, close_price: 3435, turnover: 32700, adjustment_value: 3435),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7,  5), opening_price: 3550, high_price: 3560, low_price: 3465, close_price: 3470, turnover: 23300, adjustment_value: 3470),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7,  4), opening_price: 3505, high_price: 3595, low_price: 3495, close_price: 3575, turnover: 38400, adjustment_value: 3575),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7,  3), opening_price: 3550, high_price: 3560, low_price: 3525, close_price: 3540, turnover: 23000, adjustment_value: 3540),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  7,  2), opening_price: 3600, high_price: 3600, low_price: 3510, close_price: 3520, turnover: 29200, adjustment_value: 3520),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 29), opening_price: 3650, high_price: 3650, low_price: 3575, close_price: 3595, turnover: 18200, adjustment_value: 3595),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 28), opening_price: 3615, high_price: 3615, low_price: 3555, close_price: 3605, turnover: 21800, adjustment_value: 3605),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 27), opening_price: 3610, high_price: 3655, low_price: 3555, close_price: 3630, turnover: 22200, adjustment_value: 3630),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 26), opening_price: 3570, high_price: 3625, low_price: 3535, close_price: 3615, turnover: 21800, adjustment_value: 3615),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 25), opening_price: 3640, high_price: 3640, low_price: 3570, close_price: 3590, turnover: 27200, adjustment_value: 3590),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 22), opening_price: 3650, high_price: 3660, low_price: 3610, close_price: 3640, turnover: 26400, adjustment_value: 3640),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 21), opening_price: 3680, high_price: 3700, low_price: 3665, close_price: 3680, turnover: 14700, adjustment_value: 3680),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 20), opening_price: 3690, high_price: 3715, low_price: 3665, close_price: 3705, turnover: 18800, adjustment_value: 3705),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 19), opening_price: 3710, high_price: 3710, low_price: 3645, close_price: 3660, turnover: 22100, adjustment_value: 3660),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 18), opening_price: 3780, high_price: 3780, low_price: 3710, close_price: 3720, turnover: 16700, adjustment_value: 3720),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 15), opening_price: 3780, high_price: 3785, low_price: 3755, close_price: 3760, turnover:  8300, adjustment_value: 3760),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 14), opening_price: 3780, high_price: 3800, low_price: 3775, close_price: 3780, turnover: 11200, adjustment_value: 3780),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 13), opening_price: 3785, high_price: 3800, low_price: 3785, close_price: 3785, turnover: 19700, adjustment_value: 3785),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 12), opening_price: 3810, high_price: 3820, low_price: 3790, close_price: 3790, turnover:  9200, adjustment_value: 3790),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6, 11), opening_price: 3750, high_price: 3820, low_price: 3730, close_price: 3810, turnover: 22000, adjustment_value: 3810),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6,  8), opening_price: 3715, high_price: 3765, low_price: 3705, close_price: 3755, turnover: 25200, adjustment_value: 3755),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6,  7), opening_price: 3725, high_price: 3750, low_price: 3685, close_price: 3750, turnover: 33700, adjustment_value: 3750),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6,  6), opening_price: 3755, high_price: 3770, low_price: 3725, close_price: 3725, turnover: 18000, adjustment_value: 3725),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6,  5), opening_price: 3805, high_price: 3830, low_price: 3760, close_price: 3775, turnover: 13600, adjustment_value: 3775),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6,  4), opening_price: 3765, high_price: 3810, low_price: 3765, close_price: 3805, turnover: 13500, adjustment_value: 3805),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  6,  1), opening_price: 3795, high_price: 3795, low_price: 3745, close_price: 3755, turnover: 16300, adjustment_value: 3755),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 31), opening_price: 3835, high_price: 3845, low_price: 3775, close_price: 3780, turnover: 38000, adjustment_value: 3780),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 30), opening_price: 3730, high_price: 3850, low_price: 3710, close_price: 3835, turnover: 49600, adjustment_value: 3835),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 29), opening_price: 3735, high_price: 3780, low_price: 3725, close_price: 3775, turnover: 17000, adjustment_value: 3775),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 28), opening_price: 3745, high_price: 3745, low_price: 3710, close_price: 3735, turnover: 17900, adjustment_value: 3735),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 25), opening_price: 3735, high_price: 3755, low_price: 3715, close_price: 3715, turnover: 22100, adjustment_value: 3715),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 24), opening_price: 3730, high_price: 3765, low_price: 3715, close_price: 3735, turnover: 18300, adjustment_value: 3735),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 23), opening_price: 3745, high_price: 3760, low_price: 3725, close_price: 3745, turnover: 19900, adjustment_value: 3745),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 22), opening_price: 3785, high_price: 3785, low_price: 3735, close_price: 3745, turnover: 16800, adjustment_value: 3745),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 21), opening_price: 3825, high_price: 3830, low_price: 3785, close_price: 3795, turnover: 14800, adjustment_value: 3795),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 18), opening_price: 3850, high_price: 3850, low_price: 3805, close_price: 3825, turnover: 26600, adjustment_value: 3825),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 17), opening_price: 3810, high_price: 3830, low_price: 3790, close_price: 3830, turnover: 14900, adjustment_value: 3830),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 16), opening_price: 3825, high_price: 3845, low_price: 3800, close_price: 3815, turnover: 22300, adjustment_value: 3815),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 15), opening_price: 3820, high_price: 3855, low_price: 3820, close_price: 3845, turnover: 24600, adjustment_value: 3845),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 14), opening_price: 3800, high_price: 3845, low_price: 3795, close_price: 3810, turnover: 34000, adjustment_value: 3810),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 11), opening_price: 3775, high_price: 3810, low_price: 3770, close_price: 3805, turnover: 44100, adjustment_value: 3805),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5, 10), opening_price: 3840, high_price: 3870, low_price: 3760, close_price: 3815, turnover: 44400, adjustment_value: 3815),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5,  9), opening_price: 3790, high_price: 3840, low_price: 3790, close_price: 3825, turnover: 24500, adjustment_value: 3825),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5,  8), opening_price: 3765, high_price: 3845, low_price: 3760, close_price: 3825, turnover: 32000, adjustment_value: 3825),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5,  7), opening_price: 3810, high_price: 3810, low_price: 3775, close_price: 3785, turnover: 22900, adjustment_value: 3785),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5,  2), opening_price: 3785, high_price: 3800, low_price: 3765, close_price: 3800, turnover: 12100, adjustment_value: 3800),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  5,  1), opening_price: 3770, high_price: 3785, low_price: 3755, close_price: 3785, turnover: 14300, adjustment_value: 3785),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 27), opening_price: 3725, high_price: 3775, low_price: 3715, close_price: 3775, turnover: 29400, adjustment_value: 3775),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 26), opening_price: 3725, high_price: 3730, low_price: 3705, close_price: 3725, turnover: 19600, adjustment_value: 3725),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 25), opening_price: 3705, high_price: 3740, low_price: 3705, close_price: 3725, turnover: 11900, adjustment_value: 3725),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 24), opening_price: 3710, high_price: 3740, low_price: 3705, close_price: 3725, turnover: 21500, adjustment_value: 3725),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 23), opening_price: 3730, high_price: 3730, low_price: 3690, close_price: 3705, turnover: 23100, adjustment_value: 3705),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 20), opening_price: 3775, high_price: 3775, low_price: 3745, close_price: 3755, turnover: 12200, adjustment_value: 3755),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 19), opening_price: 3750, high_price: 3760, low_price: 3735, close_price: 3755, turnover: 14300, adjustment_value: 3755),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 18), opening_price: 3760, high_price: 3775, low_price: 3735, close_price: 3750, turnover: 15000, adjustment_value: 3750),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 17), opening_price: 3800, high_price: 3815, low_price: 3755, close_price: 3755, turnover: 12200, adjustment_value: 3755),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 16), opening_price: 3755, high_price: 3805, low_price: 3740, close_price: 3800, turnover: 14700, adjustment_value: 3800),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 13), opening_price: 3770, high_price: 3785, low_price: 3740, close_price: 3760, turnover: 12800, adjustment_value: 3760),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 12), opening_price: 3750, high_price: 3770, low_price: 3740, close_price: 3760, turnover: 14500, adjustment_value: 3760),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 11), opening_price: 3810, high_price: 3815, low_price: 3745, close_price: 3755, turnover: 27100, adjustment_value: 3755),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4, 10), opening_price: 3830, high_price: 3870, low_price: 3805, close_price: 3830, turnover: 27200, adjustment_value: 3830),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4,  9), opening_price: 3765, high_price: 3850, low_price: 3760, close_price: 3830, turnover: 28600, adjustment_value: 3830),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4,  6), opening_price: 3840, high_price: 3840, low_price: 3790, close_price: 3790, turnover: 18400, adjustment_value: 3790),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4,  5), opening_price: 3805, high_price: 3830, low_price: 3795, close_price: 3810, turnover: 20600, adjustment_value: 3810),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4,  4), opening_price: 3735, high_price: 3805, low_price: 3720, close_price: 3805, turnover: 25900, adjustment_value: 3805),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4,  3), opening_price: 3690, high_price: 3755, low_price: 3680, close_price: 3735, turnover: 24500, adjustment_value: 3735),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  4,  2), opening_price: 3800, high_price: 3800, low_price: 3740, close_price: 3750, turnover: 28000, adjustment_value: 3750),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 30), opening_price: 3840, high_price: 3840, low_price: 3785, close_price: 3800, turnover: 23500, adjustment_value: 3800),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 29), opening_price: 3820, high_price: 3830, low_price: 3785, close_price: 3820, turnover: 26500, adjustment_value: 3820),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 28), opening_price: 3800, high_price: 3815, low_price: 3765, close_price: 3800, turnover: 64000, adjustment_value: 3800),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 27), opening_price: 3890, high_price: 3930, low_price: 3880, close_price: 3930, turnover: 106900, adjustment_value: 3930),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 26), opening_price: 3785, high_price: 3860, low_price: 3780, close_price: 3860, turnover: 43900, adjustment_value: 3860),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 23), opening_price: 3830, high_price: 3840, low_price: 3800, close_price: 3815, turnover: 37800, adjustment_value: 3815),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 22), opening_price: 3855, high_price: 3885, low_price: 3850, close_price: 3880, turnover: 28800, adjustment_value: 3880),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 20), opening_price: 3830, high_price: 3865, low_price: 3785, close_price: 3865, turnover: 29200, adjustment_value: 3865),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 19), opening_price: 3890, high_price: 3895, low_price: 3830, close_price: 3845, turnover: 35500, adjustment_value: 3845),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 16), opening_price: 3890, high_price: 3895, low_price: 3860, close_price: 3895, turnover: 43200, adjustment_value: 3895),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 15), opening_price: 3890, high_price: 3895, low_price: 3840, close_price: 3885, turnover: 25200, adjustment_value: 3885),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 14), opening_price: 3905, high_price: 3920, low_price: 3890, close_price: 3900, turnover: 20500, adjustment_value: 3900),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 13), opening_price: 3895, high_price: 3925, low_price: 3885, close_price: 3925, turnover: 25000, adjustment_value: 3925),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3, 12), opening_price: 3920, high_price: 3920, low_price: 3870, close_price: 3905, turnover: 31200, adjustment_value: 3905),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3,  9), opening_price: 3895, high_price: 3920, low_price: 3845, close_price: 3875, turnover: 41500, adjustment_value: 3875),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3,  8), opening_price: 3865, high_price: 3875, low_price: 3830, close_price: 3865, turnover: 29100, adjustment_value: 3865),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3,  7), opening_price: 3815, high_price: 3860, low_price: 3795, close_price: 3820, turnover: 22900, adjustment_value: 3820),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3,  6), opening_price: 3780, high_price: 3825, low_price: 3780, close_price: 3815, turnover: 24300, adjustment_value: 3815),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3,  5), opening_price: 3770, high_price: 3815, low_price: 3740, close_price: 3760, turnover: 30900, adjustment_value: 3760),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3,  2), opening_price: 3745, high_price: 3755, low_price: 3700, close_price: 3740, turnover: 31100, adjustment_value: 3740),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  3,  1), opening_price: 3825, high_price: 3825, low_price: 3765, close_price: 3770, turnover: 39400, adjustment_value: 3770),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 28), opening_price: 3845, high_price: 3885, low_price: 3835, close_price: 3835, turnover: 51700, adjustment_value: 3835),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 27), opening_price: 3915, high_price: 3920, low_price: 3850, close_price: 3855, turnover: 44200, adjustment_value: 3855),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 26), opening_price: 3950, high_price: 3955, low_price: 3905, close_price: 3915, turnover: 30800, adjustment_value: 3915),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 23), opening_price: 3875, high_price: 3930, low_price: 3875, close_price: 3930, turnover: 22600, adjustment_value: 3930),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 22), opening_price: 3925, high_price: 3925, low_price: 3825, close_price: 3870, turnover: 28800, adjustment_value: 3870),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 21), opening_price: 3920, high_price: 3945, low_price: 3875, close_price: 3915, turnover: 27000, adjustment_value: 3915),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 20), opening_price: 3920, high_price: 3920, low_price: 3870, close_price: 3895, turnover: 27600, adjustment_value: 3895),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 19), opening_price: 3850, high_price: 3890, low_price: 3845, close_price: 3880, turnover: 24000, adjustment_value: 3880),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 16), opening_price: 3740, high_price: 3835, low_price: 3740, close_price: 3820, turnover: 47100, adjustment_value: 3820),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 15), opening_price: 3705, high_price: 3730, low_price: 3675, close_price: 3715, turnover: 48600, adjustment_value: 3715),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 14), opening_price: 3700, high_price: 3735, low_price: 3645, close_price: 3700, turnover: 49200, adjustment_value: 3700),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2, 13), opening_price: 3850, high_price: 3860, low_price: 3680, close_price: 3695, turnover: 81400, adjustment_value: 3695),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2,  9), opening_price: 3800, high_price: 3865, low_price: 3770, close_price: 3810, turnover: 72200, adjustment_value: 3810),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2,  8), opening_price: 3880, high_price: 3925, low_price: 3870, close_price: 3885, turnover: 31800, adjustment_value: 3885),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2,  7), opening_price: 3995, high_price: 4050, low_price: 3875, close_price: 3880, turnover: 47600, adjustment_value: 3880),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2,  6), opening_price: 3910, high_price: 3910, low_price: 3830, close_price: 3900, turnover: 89200, adjustment_value: 3900),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2,  5), opening_price: 4100, high_price: 4125, low_price: 4055, close_price: 4085, turnover: 49200, adjustment_value: 4085),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2,  2), opening_price: 4150, high_price: 4180, low_price: 4140, close_price: 4175, turnover: 20700, adjustment_value: 4175),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  2,  1), opening_price: 4150, high_price: 4195, low_price: 4130, close_price: 4170, turnover: 21400, adjustment_value: 4170),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 31), opening_price: 4160, high_price: 4210, low_price: 4140, close_price: 4140, turnover: 41700, adjustment_value: 4140),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 30), opening_price: 4250, high_price: 4250, low_price: 4170, close_price: 4190, turnover: 38400, adjustment_value: 4190),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 29), opening_price: 4290, high_price: 4345, low_price: 4270, close_price: 4270, turnover: 32600, adjustment_value: 4270),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 26), opening_price: 4280, high_price: 4305, low_price: 4275, close_price: 4290, turnover: 26400, adjustment_value: 4290),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 25), opening_price: 4260, high_price: 4300, low_price: 4210, close_price: 4280, turnover: 40900, adjustment_value: 4280),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 24), opening_price: 4265, high_price: 4290, low_price: 4250, close_price: 4260, turnover: 32400, adjustment_value: 4260),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 23), opening_price: 4300, high_price: 4305, low_price: 4255, close_price: 4260, turnover: 54000, adjustment_value: 4260),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 22), opening_price: 4230, high_price: 4240, low_price: 4160, close_price: 4190, turnover: 41000, adjustment_value: 4190),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 19), opening_price: 4165, high_price: 4250, low_price: 4160, close_price: 4230, turnover: 55000, adjustment_value: 4230),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 18), opening_price: 4275, high_price: 4280, low_price: 4160, close_price: 4170, turnover: 47300, adjustment_value: 4170),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 17), opening_price: 4300, high_price: 4315, low_price: 4250, close_price: 4255, turnover: 31200, adjustment_value: 4255),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 16), opening_price: 4250, high_price: 4325, low_price: 4230, close_price: 4305, turnover: 37300, adjustment_value: 4305),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 15), opening_price: 4280, high_price: 4285, low_price: 4255, close_price: 4260, turnover: 31100, adjustment_value: 4260),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 12), opening_price: 4345, high_price: 4345, low_price: 4265, close_price: 4270, turnover: 42500, adjustment_value: 4270),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 11), opening_price: 4430, high_price: 4430, low_price: 4340, close_price: 4350, turnover: 48200, adjustment_value: 4350),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1, 10), opening_price: 4340, high_price: 4460, low_price: 4340, close_price: 4430, turnover: 91300, adjustment_value: 4430),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1,  9), opening_price: 4340, high_price: 4360, low_price: 4325, close_price: 4340, turnover: 26100, adjustment_value: 4340),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1,  5), opening_price: 4330, high_price: 4360, low_price: 4285, close_price: 4340, turnover: 55300, adjustment_value: 4340),
        have_attributes(ticker_symbol: "1301", date: Time.local(2018,  1,  4), opening_price: 4270, high_price: 4335, low_price: 4220, close_price: 4320, turnover: 61500, adjustment_value: 4320),
        have_attributes(ticker_symbol: "1301", date: Time.local(2017, 12, 29), opening_price: 4310, high_price: 4315, low_price: 4280, close_price: 4295, turnover: 16400, adjustment_value: 4295),
        have_attributes(ticker_symbol: "1301", date: Time.local(2017, 12, 28), opening_price: 4270, high_price: 4325, low_price: 4230, close_price: 4310, turnover: 58100, adjustment_value: 4310),
      ])
    end

    it "not stored duplicate data" do
      @parser.parse({})

      url = "https://kabuoji3.com/stock/1301/"
      data = {
        "url" => "https://kabuoji3.com/stock/1301/",
        "request_method" => "GET",
        "request_headers" => {},
        "response_headers" => {},
        "response_body" => File.open("spec/data/stock_prices_page.1301.html").read,
        "downloaded_timestamp" => Time.utc(2019, 3, 24, 3, 11, 23)}

      parser2 = InvestmentMachine::Parser::StockPricesPageParser.new(url, data)
      parser2.parse({})

      expect(InvestmentMachine::Model::Company.all.count).to eq 1
      expect(InvestmentMachine::Model::StockPrice.all.count).to eq 300
    end
  end
end

