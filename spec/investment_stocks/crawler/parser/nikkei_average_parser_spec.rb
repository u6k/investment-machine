require "timecop"
require "webmock/rspec"

RSpec.describe InvestmentStocks::Crawler::Parser::NikkeiAverageIndexParser do
  before do
    @downloader = Crawline::Downloader.new("investment-stocks-crawler/#{InvestmentStocks::Crawler::VERSION}")

    WebMock.enable!

    @url = "https://indexes.nikkei.co.jp/nkave/archives/data"
    WebMock.stub_request(:get, @url).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/nikkei_average.index.html").read)

    @parser = InvestmentStocks::Crawler::Parser::NikkeiAverageIndexParser.new(@url, @downloader.download_with_get(@url))

    WebMock.disable!
  end

  describe "#redownload?" do
    it "is always true" do
      expect(@parser).to be_redownload
    end
  end

  describe "#valid?" do
    context "local data" do
      it "is valid" do
        expect(@parser).to be_valid
      end
    end

    context "data on web" do
      it "is valid" do
        data = @downloader.download_with_get(@url)
        parser = InvestmentStocks::Crawler::Parser::NikkeiAverageIndexParser.new(@url, data)

        expect(parser).to be_valid
      end
    end
  end

  describe "#related_links" do
    it "is nikkei average daily data pages" do
      expected_links = []

      (1949..2019).map do |y|
        (1..12).map do |m|
          expected_links << "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=#{y}&month=#{m}"
        end
      end

      expect(@parser.related_links).to match_array(expected_links)
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

RSpec.describe InvestmentStocks::Crawler::Parser::NikkeiAverageDataParser do
  before do
    # Setup database
    InvestmentStocks::Crawler::Model::NikkeiAverage.delete_all

    # Setup parser
    @downloader = Crawline::Downloader.new("investment-stocks-crawler/#{InvestmentStocks::Crawler::VERSION}")

    WebMock.enable!

    @url_194901 = "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=1949&month=1"
    WebMock.stub_request(:get, @url_194901).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/nikkei_average.194901.html").read)

    @parser_194901 = InvestmentStocks::Crawler::Parser::NikkeiAverageDataParser.new(@url_194901, @downloader.download_with_get(@url_194901))

    @url_194905 = "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=1949&month=5"
    WebMock.stub_request(:get, @url_194905).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/nikkei_average.194905.html").read)

    @parser_194905 = InvestmentStocks::Crawler::Parser::NikkeiAverageDataParser.new(@url_194905, @downloader.download_with_get(@url_194905))

    @url_201902 = "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=2019&month=2"
    WebMock.stub_request(:get, @url_201902).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/nikkei_average.201902.html").read)

    @parser_201902 = InvestmentStocks::Crawler::Parser::NikkeiAverageDataParser.new(@url_201902, @downloader.download_with_get(@url_201902))

    WebMock.disable!
  end

  describe "#redownload?" do
    context "2019-02" do
      it "redownload if newer than 2 months(60 days)" do
        Timecop.freeze(Time.local(2019, 4, 1, 23, 59, 59)) do
          expect(@parser_201902).to be_redownload
        end
      end

      it "do not redownload if over 2 months(60 days) old" do
        Timecop.freeze(Time.local(2019, 4, 2, 0, 0, 0)) do
          expect(@parser_201902).not_to be_redownload
        end
      end
    end
  end

  describe "#valid?" do
    context "2019-02" do
      it "is valid" do
        expect(@parser_201902).to be_valid
      end
    end

    context "1949-05" do
      it "is valid" do
        expect(@parser_194905).to be_valid
      end
    end

    context "1949-01 (empty data)" do
      it "is invalid" do
        expect(@parser_194901).not_to be_valid
      end
    end

    context "data on web" do
      it "is valid(2019-02)" do
        data = @downloader.download_with_get(@url_201902)
        parser = InvestmentStocks::Crawler::Parser::NikkeiAverageDataParser.new(@url_201902, @downloader.download_with_get(@url_201902))

        expect(parser).to be_valid
      end

      it "is valid(1949-05)" do
        data = @downloader.download_with_get(@url_194905)
        parser = InvestmentStocks::Crawler::Parser::NikkeiAverageDataParser.new(@url_194905, @downloader.download_with_get(@url_194905))

        expect(parser).to be_valid
      end

      it "is invalid(1949-01)" do
        data = @downloader.download_with_get(@url_194901)
        parser = InvestmentStocks::Crawler::Parser::NikkeiAverageDataParser.new(@url_194901, @downloader.download_with_get(@url_194901))

        expect(parser).not_to be_valid
      end
    end
  end

  describe "#related_links" do
    context "2019-02" do
      it "is nil" do
        expect(@parser_201902.related_links).to be_nil
      end
    end
  end

  describe "#parse" do
    context "2019-02" do
      it "is prices" do
        context = {}

        @parser_201902.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::NikkeiAverage.all).to match_array([
          have_attributes(date: Time.local(2019, 2, 1), open_price: 20797.03, high_price: 20929.63, low_price: 20741.98, close_price: 20788.39),
          have_attributes(date: Time.local(2019, 2, 4), open_price: 20831.90, high_price: 20922.58, low_price: 20823.68, close_price: 20883.77),
          have_attributes(date: Time.local(2019, 2, 5), open_price: 20960.47, high_price: 20981.23, low_price: 20823.18, close_price: 20844.45),
          have_attributes(date: Time.local(2019, 2, 6), open_price: 20928.87, high_price: 20971.66, low_price: 20860.99, close_price: 20874.06),
          have_attributes(date: Time.local(2019, 2, 7), open_price: 20812.22, high_price: 20844.77, low_price: 20665.51, close_price: 20751.28),
          have_attributes(date: Time.local(2019, 2, 8), open_price: 20510.50, high_price: 20562.39, low_price: 20315.31, close_price: 20333.17),
          have_attributes(date: Time.local(2019, 2, 12), open_price: 20442.55, high_price: 20885.88, low_price: 20428.57, close_price: 20864.21),
          have_attributes(date: Time.local(2019, 2, 13), open_price: 21029.93, high_price: 21213.74, low_price: 20992.88, close_price: 21144.48),
          have_attributes(date: Time.local(2019, 2, 14), open_price: 21147.89, high_price: 21235.62, low_price: 21102.16, close_price: 21139.71),
          have_attributes(date: Time.local(2019, 2, 15), open_price: 21051.51, high_price: 21051.51, low_price: 20853.33, close_price: 20900.63),
          have_attributes(date: Time.local(2019, 2, 18), open_price: 21217.32, high_price: 21306.36, low_price: 21189.97, close_price: 21281.85),
          have_attributes(date: Time.local(2019, 2, 19), open_price: 21256.58, high_price: 21344.17, low_price: 21217.16, close_price: 21302.65),
          have_attributes(date: Time.local(2019, 2, 20), open_price: 21346.04, high_price: 21494.85, low_price: 21315.39, close_price: 21431.49),
          have_attributes(date: Time.local(2019, 2, 21), open_price: 21422.31, high_price: 21553.35, low_price: 21318.74, close_price: 21464.23),
          have_attributes(date: Time.local(2019, 2, 22), open_price: 21376.36, high_price: 21451.23, low_price: 21348.67, close_price: 21425.51),
          have_attributes(date: Time.local(2019, 2, 25), open_price: 21567.66, high_price: 21590.03, low_price: 21505.07, close_price: 21528.23),
          have_attributes(date: Time.local(2019, 2, 26), open_price: 21556.02, high_price: 21610.88, low_price: 21405.84, close_price: 21449.39),
          have_attributes(date: Time.local(2019, 2, 27), open_price: 21504.61, high_price: 21578.81, low_price: 21492.65, close_price: 21556.51),
          have_attributes(date: Time.local(2019, 2, 28), open_price: 21536.55, high_price: 21536.55, low_price: 21364.09, close_price: 21385.16),
        ])
      end
    end

    context "1949-05" do
      it "is prices" do
        context = {}

        @parser_194905.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::NikkeiAverage.all).to match_array([
          have_attributes(date: Time.local(1949, 5, 16), open_price: nil, high_price: nil, low_price: nil, close_price: 176.21),
          have_attributes(date: Time.local(1949, 5, 17), open_price: nil, high_price: nil, low_price: nil, close_price: 174.80),
          have_attributes(date: Time.local(1949, 5, 18), open_price: nil, high_price: nil, low_price: nil, close_price: 172.53),
          have_attributes(date: Time.local(1949, 5, 19), open_price: nil, high_price: nil, low_price: nil, close_price: 171.34),
          have_attributes(date: Time.local(1949, 5, 20), open_price: nil, high_price: nil, low_price: nil, close_price: 169.20),
          have_attributes(date: Time.local(1949, 5, 21), open_price: nil, high_price: nil, low_price: nil, close_price: 169.92),
          have_attributes(date: Time.local(1949, 5, 23), open_price: nil, high_price: nil, low_price: nil, close_price: 171.85),
          have_attributes(date: Time.local(1949, 5, 24), open_price: nil, high_price: nil, low_price: nil, close_price: 172.75),
          have_attributes(date: Time.local(1949, 5, 25), open_price: nil, high_price: nil, low_price: nil, close_price: 171.53),
          have_attributes(date: Time.local(1949, 5, 26), open_price: nil, high_price: nil, low_price: nil, close_price: 170.43),
          have_attributes(date: Time.local(1949, 5, 27), open_price: nil, high_price: nil, low_price: nil, close_price: 172.76),
          have_attributes(date: Time.local(1949, 5, 28), open_price: nil, high_price: nil, low_price: nil, close_price: 176.30),
          have_attributes(date: Time.local(1949, 5, 30), open_price: nil, high_price: nil, low_price: nil, close_price: 176.21),
          have_attributes(date: Time.local(1949, 5, 31), open_price: nil, high_price: nil, low_price: nil, close_price: 176.52),
        ])
      end
    end

    context "1949-01 (empty data)" do
      it "is empty" do
        context = {}

        @parser_194901.parse(context)

        expect(context).to be_empty
      end
    end

    context "existing data" do
      before do
        InvestmentStocks::Crawler::Model::NikkeiAverage.create(date: Time.new(2019,  1, 31), open_price: 2019.0131, high_price: 2019.0131, low_price: 2019.0131, close_price: 2019.0131)
        InvestmentStocks::Crawler::Model::NikkeiAverage.create(date: Time.new(2019,  2,  1), open_price: 2019.0201, high_price: 2019.0201, low_price: 2019.0201, close_price: 2019.0201)
        InvestmentStocks::Crawler::Model::NikkeiAverage.create(date: Time.new(2019,  2, 28), open_price: 2019.0228, high_price: 2019.0228, low_price: 2019.0228, close_price: 2019.0228)
        InvestmentStocks::Crawler::Model::NikkeiAverage.create(date: Time.new(2019,  3,  1), open_price: 2019.0301, high_price: 2019.0301, low_price: 2019.0301, close_price: 2019.0301)
      end

      it "is pries" do
        context = {}

        @parser_201902.parse(context)

        expect(context).to be_empty

        expect(InvestmentStocks::Crawler::Model::NikkeiAverage.all).to match_array([
          have_attributes(date: Time.local(2019, 1, 31), open_price: 2019.0131, high_price: 2019.0131, low_price: 2019.0131, close_price: 2019.0131),
          have_attributes(date: Time.local(2019, 3,  1), open_price: 2019.0301, high_price: 2019.0301, low_price: 2019.0301, close_price: 2019.0301),

          have_attributes(date: Time.local(2019, 2, 1), open_price: 20797.03, high_price: 20929.63, low_price: 20741.98, close_price: 20788.39),
          have_attributes(date: Time.local(2019, 2, 4), open_price: 20831.90, high_price: 20922.58, low_price: 20823.68, close_price: 20883.77),
          have_attributes(date: Time.local(2019, 2, 5), open_price: 20960.47, high_price: 20981.23, low_price: 20823.18, close_price: 20844.45),
          have_attributes(date: Time.local(2019, 2, 6), open_price: 20928.87, high_price: 20971.66, low_price: 20860.99, close_price: 20874.06),
          have_attributes(date: Time.local(2019, 2, 7), open_price: 20812.22, high_price: 20844.77, low_price: 20665.51, close_price: 20751.28),
          have_attributes(date: Time.local(2019, 2, 8), open_price: 20510.50, high_price: 20562.39, low_price: 20315.31, close_price: 20333.17),
          have_attributes(date: Time.local(2019, 2, 12), open_price: 20442.55, high_price: 20885.88, low_price: 20428.57, close_price: 20864.21),
          have_attributes(date: Time.local(2019, 2, 13), open_price: 21029.93, high_price: 21213.74, low_price: 20992.88, close_price: 21144.48),
          have_attributes(date: Time.local(2019, 2, 14), open_price: 21147.89, high_price: 21235.62, low_price: 21102.16, close_price: 21139.71),
          have_attributes(date: Time.local(2019, 2, 15), open_price: 21051.51, high_price: 21051.51, low_price: 20853.33, close_price: 20900.63),
          have_attributes(date: Time.local(2019, 2, 18), open_price: 21217.32, high_price: 21306.36, low_price: 21189.97, close_price: 21281.85),
          have_attributes(date: Time.local(2019, 2, 19), open_price: 21256.58, high_price: 21344.17, low_price: 21217.16, close_price: 21302.65),
          have_attributes(date: Time.local(2019, 2, 20), open_price: 21346.04, high_price: 21494.85, low_price: 21315.39, close_price: 21431.49),
          have_attributes(date: Time.local(2019, 2, 21), open_price: 21422.31, high_price: 21553.35, low_price: 21318.74, close_price: 21464.23),
          have_attributes(date: Time.local(2019, 2, 22), open_price: 21376.36, high_price: 21451.23, low_price: 21348.67, close_price: 21425.51),
          have_attributes(date: Time.local(2019, 2, 25), open_price: 21567.66, high_price: 21590.03, low_price: 21505.07, close_price: 21528.23),
          have_attributes(date: Time.local(2019, 2, 26), open_price: 21556.02, high_price: 21610.88, low_price: 21405.84, close_price: 21449.39),
          have_attributes(date: Time.local(2019, 2, 27), open_price: 21504.61, high_price: 21578.81, low_price: 21492.65, close_price: 21556.51),
          have_attributes(date: Time.local(2019, 2, 28), open_price: 21536.55, high_price: 21536.55, low_price: 21364.09, close_price: 21385.16),
        ])
      end
    end
  end
end

