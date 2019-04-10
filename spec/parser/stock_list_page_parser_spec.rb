require "timecop"
require "webmock/rspec"

RSpec.describe InvestmentMachine::Parser::StockListPageParser do
  before do
    @downloader = Crawline::Downloader.new("investment-machine/#{InvestmentMachine::VERSION}")

    WebMock.enable!

    @url = "https://kabuoji3.com/stock/"
    WebMock.stub_request(:get, @url).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_list_page.html").read)

    Timecop.freeze(Time.utc(2019, 3, 23, 16, 18, 32)) do
      @parser = InvestmentMachine::Parser::StockListPageParser.new(@url, @downloader.download_with_get(@url))
    end

    @url_error = "https://kabuoji3.com/stock/?page=abc"
    WebMock.stub_request(:get, @url_error).to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_list_page.error.html").read)

    @parser_error = InvestmentMachine::Parser::StockListPageParser.new(@url_error, @downloader.download_with_get(@url_error))

    WebMock.disable!
  end

  describe "#redownload?" do
    it "redownload if 23 hours has passed" do
      Timecop.freeze(Time.utc(2019, 3, 24, 15, 18, 33)) do
        expect(@parser).to be_redownload
      end
    end

    it "do not redownload within 23 hours" do
      Timecop.freeze(Time.utc(2019, 3, 24, 15, 18, 32)) do
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
        parser = InvestmentMachine::Parser::StockListPageParser.new(@url, data)

        expect(parser).to be_valid
      end
    end
  end

  describe "#related_links" do
    it "is stock list pages, and stock price list pages" do
      expect(@parser.related_links).to contain_exactly(
        "https://kabuoji3.com/stock/?page=1",
        "https://kabuoji3.com/stock/?page=2",
        "https://kabuoji3.com/stock/?page=3",
        "https://kabuoji3.com/stock/?page=4",
        "https://kabuoji3.com/stock/?page=5",
        "https://kabuoji3.com/stock/?page=6",
        "https://kabuoji3.com/stock/?page=7",
        "https://kabuoji3.com/stock/?page=8",
        "https://kabuoji3.com/stock/?page=9",
        "https://kabuoji3.com/stock/?page=10",
        "https://kabuoji3.com/stock/?page=11",
        "https://kabuoji3.com/stock/?page=12",
        "https://kabuoji3.com/stock/?page=13",
        "https://kabuoji3.com/stock/?page=14",
        "https://kabuoji3.com/stock/?page=15",
        "https://kabuoji3.com/stock/?page=16",
        "https://kabuoji3.com/stock/?page=17",
        "https://kabuoji3.com/stock/?page=18",
        "https://kabuoji3.com/stock/?page=19",
        "https://kabuoji3.com/stock/?page=20",
        "https://kabuoji3.com/stock/?page=21",
        "https://kabuoji3.com/stock/?page=22",
        "https://kabuoji3.com/stock/?page=23",
        "https://kabuoji3.com/stock/?page=24",
        "https://kabuoji3.com/stock/?page=25",
        "https://kabuoji3.com/stock/?page=26",
        "https://kabuoji3.com/stock/?page=27",
        "https://kabuoji3.com/stock/?page=28",
        "https://kabuoji3.com/stock/?page=29",
        "https://kabuoji3.com/stock/?page=30",
        "https://kabuoji3.com/stock/?page=31",
        "https://kabuoji3.com/stock/?page=32",
        "https://kabuoji3.com/stock/?page=33",
        "https://kabuoji3.com/stock/1301/",
        "https://kabuoji3.com/stock/1305/",
        "https://kabuoji3.com/stock/1306/",
        "https://kabuoji3.com/stock/1308/",
        "https://kabuoji3.com/stock/1309/",
        "https://kabuoji3.com/stock/1310/",
        "https://kabuoji3.com/stock/1311/",
        "https://kabuoji3.com/stock/1312/",
        "https://kabuoji3.com/stock/1313/",
        "https://kabuoji3.com/stock/1320/",
        "https://kabuoji3.com/stock/1321/",
        "https://kabuoji3.com/stock/1322/",
        "https://kabuoji3.com/stock/1324/",
        "https://kabuoji3.com/stock/1325/",
        "https://kabuoji3.com/stock/1326/",
        "https://kabuoji3.com/stock/1327/",
        "https://kabuoji3.com/stock/1328/",
        "https://kabuoji3.com/stock/1329/",
        "https://kabuoji3.com/stock/1330/",
        "https://kabuoji3.com/stock/1332/",
        "https://kabuoji3.com/stock/1333/",
        "https://kabuoji3.com/stock/1343/",
        "https://kabuoji3.com/stock/1344/",
        "https://kabuoji3.com/stock/1345/",
        "https://kabuoji3.com/stock/1346/",
        "https://kabuoji3.com/stock/1348/",
        "https://kabuoji3.com/stock/1349/",
        "https://kabuoji3.com/stock/1352/",
        "https://kabuoji3.com/stock/1356/",
        "https://kabuoji3.com/stock/1357/",
        "https://kabuoji3.com/stock/1358/",
        "https://kabuoji3.com/stock/1360/",
        "https://kabuoji3.com/stock/1364/",
        "https://kabuoji3.com/stock/1365/",
        "https://kabuoji3.com/stock/1366/",
        "https://kabuoji3.com/stock/1367/",
        "https://kabuoji3.com/stock/1368/",
        "https://kabuoji3.com/stock/1369/",
        "https://kabuoji3.com/stock/1376/",
        "https://kabuoji3.com/stock/1377/",
        "https://kabuoji3.com/stock/1379/",
        "https://kabuoji3.com/stock/1380/",
        "https://kabuoji3.com/stock/1381/",
        "https://kabuoji3.com/stock/1383/",
        "https://kabuoji3.com/stock/1384/",
        "https://kabuoji3.com/stock/1385/",
        "https://kabuoji3.com/stock/1386/",
        "https://kabuoji3.com/stock/1388/",
        "https://kabuoji3.com/stock/1390/",
        "https://kabuoji3.com/stock/1391/",
        "https://kabuoji3.com/stock/1392/",
        "https://kabuoji3.com/stock/1393/",
        "https://kabuoji3.com/stock/1398/",
        "https://kabuoji3.com/stock/1399/",
        "https://kabuoji3.com/stock/1400/",
        "https://kabuoji3.com/stock/1401/",
        "https://kabuoji3.com/stock/1407/",
        "https://kabuoji3.com/stock/1414/",
        "https://kabuoji3.com/stock/1417/",
        "https://kabuoji3.com/stock/1418/",
        "https://kabuoji3.com/stock/1419/",
        "https://kabuoji3.com/stock/1420/",
        "https://kabuoji3.com/stock/1429/",
        "https://kabuoji3.com/stock/1430/",
        "https://kabuoji3.com/stock/1431/",
        "https://kabuoji3.com/stock/1433/",
        "https://kabuoji3.com/stock/1434/",
        "https://kabuoji3.com/stock/1435/",
        "https://kabuoji3.com/stock/1436/",
        "https://kabuoji3.com/stock/1438/",
        "https://kabuoji3.com/stock/1439/",
        "https://kabuoji3.com/stock/1443/",
        "https://kabuoji3.com/stock/1446/",
        "https://kabuoji3.com/stock/1447/",
        "https://kabuoji3.com/stock/1448/",
        "https://kabuoji3.com/stock/1449/",
        "https://kabuoji3.com/stock/1450/",
        "https://kabuoji3.com/stock/1451/",
        "https://kabuoji3.com/stock/1456/",
        "https://kabuoji3.com/stock/1457/",
        "https://kabuoji3.com/stock/1458/",
        "https://kabuoji3.com/stock/1459/",
        "https://kabuoji3.com/stock/1464/",
        "https://kabuoji3.com/stock/1465/",
        "https://kabuoji3.com/stock/1466/",
        "https://kabuoji3.com/stock/1467/",
        "https://kabuoji3.com/stock/1469/",
        "https://kabuoji3.com/stock/1470/",
        "https://kabuoji3.com/stock/1472/",
        "https://kabuoji3.com/stock/1473/",
        "https://kabuoji3.com/stock/1474/",
        "https://kabuoji3.com/stock/1475/",
        "https://kabuoji3.com/stock/1476/",
        "https://kabuoji3.com/stock/1477/",
        "https://kabuoji3.com/stock/1478/",
        "https://kabuoji3.com/stock/1479/",
        "https://kabuoji3.com/stock/1481/",
        "https://kabuoji3.com/stock/1482/",
        "https://kabuoji3.com/stock/1483/",
        "https://kabuoji3.com/stock/1484/",
        "https://kabuoji3.com/stock/1486/",
        "https://kabuoji3.com/stock/1487/",
        "https://kabuoji3.com/stock/1488/",
        "https://kabuoji3.com/stock/1489/",
        "https://kabuoji3.com/stock/1491/",
        "https://kabuoji3.com/stock/1492/",
        "https://kabuoji3.com/stock/1493/",
        "https://kabuoji3.com/stock/1494/",
        "https://kabuoji3.com/stock/1495/",
        "https://kabuoji3.com/stock/1496/",
        "https://kabuoji3.com/stock/1497/",
        "https://kabuoji3.com/stock/1498/",
        "https://kabuoji3.com/stock/1499/",
        "https://kabuoji3.com/stock/1514/",
        "https://kabuoji3.com/stock/1515/",
        "https://kabuoji3.com/stock/1518/",
        "https://kabuoji3.com/stock/1540/",
        "https://kabuoji3.com/stock/1541/",
        "https://kabuoji3.com/stock/1542/",
        "https://kabuoji3.com/stock/1543/",
      )
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

