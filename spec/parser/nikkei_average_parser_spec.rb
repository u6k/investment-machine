require "timecop"

RSpec.describe InvestmentMachine::Parser::NikkeiAverageIndexParser do
  before do
    url = "https://indexes.nikkei.co.jp/nkave/archives/"
    data = {
      "url" => "https://indexes.nikkei.co.jp/nkave/archives/",
      "request_method" => "GET",
      "request_headers" => {},
      "response_headers" => {},
      "response_body" => File.open("spec/data/nikkei_aberage.index.html").read,
      "downloaded_timestamp" => Time.utc(2019, 3, 27, 20, 35, 12)}

    @parser = InvestmentMachine::Parser::NikkeiAverageIndexParser.new(url, data)
  end

  describe "#redownload?" do
    it "redownload if 23 hours has passed" do
      Timecop.freeze(Time.utc(2019, 3, 28, 19, 35, 13)) do
        expect(@parser).to be_redownload
      end
    end

    it "do not redownload within 23 hours" do
      Timecop.freeze(Time.utc(2019, 3, 28, 19, 35, 12)) do
        expect(@parser).not_to be_redownload
      end
    end
  end

  describe "#valid?" do
    it "is valid" do
      expect(@parser).to be_valid
    end
  end

  describe "#related_links" do
    it "is nikkei average daily data pages" do
      expected_links = (1946..2019).map do |y|
        (1..12).map do |m|
          "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=#{y}&month=#{m}"
        end
      end

      expect(@parser.related_links).to match_array(expected_links)
    end
  end

  describe "#parse" do
    it "is empty" do
      context = {}

      @parser.parse(context).to be_empty
    end
  end
end

