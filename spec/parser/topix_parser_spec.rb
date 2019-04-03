require "timecop"

RSpec.describe InvestmentMachine::Parser::TopixIndexPageParser do
  before do
    url = "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/"
    data = {
      "url" => url,
      "request_method" => "GET",
      "request_headers" => {},
      "response_headers" => {},
      "response_body" => "test",
      "downloaded_timestamp" => Time.utc(2018, 4, 3, 17, 23, 27)}

    @parser = InvestmentMachine::Parser::TopixIndexPageParser.new(url, data)
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
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1990&endDate=12/31/1990",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1991&endDate=12/31/1991",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1992&endDate=12/31/1992",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1993&endDate=12/31/1993",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1994&endDate=12/31/1994",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1995&endDate=12/31/1995",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1996&endDate=12/31/1996",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1997&endDate=12/31/1997",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1998&endDate=12/31/1998",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1999&endDate=12/31/1999",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2000&endDate=12/31/2000",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2001&endDate=12/31/2001",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2002&endDate=12/31/2002",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2003&endDate=12/31/2003",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2004&endDate=12/31/2004",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2005&endDate=12/31/2005",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2006&endDate=12/31/2006",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2007&endDate=12/31/2007",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2008&endDate=12/31/2008",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2009&endDate=12/31/2009",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2010&endDate=12/31/2010",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2011&endDate=12/31/2011",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2012&endDate=12/31/2012",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2013&endDate=12/31/2013",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2014&endDate=12/31/2014",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2015&endDate=12/31/2015",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2016&endDate=12/31/2016",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2017&endDate=12/31/2017",
        "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2018&endDate=12/31/2018")
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

RSpec.describe InvestmentMachine::Parser::TopixCsvParser do
  before do
    # Cleanup database
    InvestmentMachine::Model::Topix.delete_all

    # Setup parser
    url = "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2019&endDate=12/31/2019"
    data = {
      "url" => url,
      "request_method" => "GET",
      "request_headers" => {},
      "response_headers" => {},
      "response_body" => File.open("spec/data/topix.2019.csv").read,
      "downloaded_timestamp" => Time.utc(2019, 4, 3, 17, 31, 27)}

    @parser_2019 = InvestmentMachine::Parser::TopixCsvParser.new(url, data)

    url = "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1990&endDate=12/31/1990"
    data = {
      "url" => url,
      "request_method" => "GET",
      "request_headers" => {},
      "response_headers" => {},
      "response_body" => File.open("spec/data/topix.1990.csv").read,
      "downloaded_timestamp" => Time.utc(1990, 4, 3, 17, 30, 52)}

    @parser_1990 = InvestmentMachine::Parser::TopixCsvParser.new(url, data)
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

    context "2019s" do
      it "is valid" do
        expect(@parser_2019).to be_valid
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
      it "is indexes" do
        context = {}
  
        @parser_1990.parse(context)
  
        expect(context).to be_empty

        expect(InvestmentMachine::Model::Topix.all).to match_array([
          have_attributes(date: Time.local(1990, 12, 28), opening_price: 1733.83, high_price: 1742.77, low_price: 1726.69, close_price: 1733.83),
          have_attributes(date: Time.local(1990, 12, 27), opening_price: 1740.55, high_price: 1750.92, low_price: 1729.99, close_price: 1740.55),
          have_attributes(date: Time.local(1990, 12, 26), opening_price: 1729.81, high_price: 1731.47, low_price: 1720.22, close_price: 1729.81),
          have_attributes(date: Time.local(1990, 12, 25), opening_price: 1725.17, high_price: 1762.32, low_price: 1725.17, close_price: 1725.17),
          have_attributes(date: Time.local(1990, 12, 21), opening_price: 1764.82, high_price: 1792.93, low_price: 1754.99, close_price: 1764.82),
          have_attributes(date: Time.local(1990, 12, 20), opening_price: 1795.37, high_price: 1819.94, low_price: 1794.65, close_price: 1795.37),
          have_attributes(date: Time.local(1990, 12, 19), opening_price: 1821.41, high_price: 1833.84, low_price: 1792.47, close_price: 1821.41),
          have_attributes(date: Time.local(1990, 12, 18), opening_price: 1790.48, high_price: 1790.48, low_price: 1776.89, close_price: 1790.48),
          have_attributes(date: Time.local(1990, 12, 17), opening_price: 1778.89, high_price: 1799.54, low_price: 1777.26, close_price: 1778.89),
          have_attributes(date: Time.local(1990, 12, 14), opening_price: 1800.32, high_price: 1813.48, low_price: 1786.86, close_price: 1800.32),
          have_attributes(date: Time.local(1990, 12, 13), opening_price: 1813.98, high_price: 1813.98, low_price: 1781.16, close_price: 1813.98),
          have_attributes(date: Time.local(1990, 12, 12), opening_price: 1779.50, high_price: 1789.77, low_price: 1768.98, close_price: 1779.50),
          have_attributes(date: Time.local(1990, 12, 11), opening_price: 1771.63, high_price: 1771.63, low_price: 1739.63, close_price: 1771.63),
          have_attributes(date: Time.local(1990, 12, 10), opening_price: 1757.02, high_price: 1764.89, low_price: 1735.05, close_price: 1757.02),
          have_attributes(date: Time.local(1990, 12, 7), opening_price: 1740.34, high_price: 1740.49, low_price: 1669.75, close_price: 1740.34),
          have_attributes(date: Time.local(1990, 12, 6), opening_price: 1667.80, high_price: 1670.22, low_price: 1641.28, close_price: 1667.80),
          have_attributes(date: Time.local(1990, 12, 5), opening_price: 1639.13, high_price: 1639.15, low_price: 1610.22, close_price: 1639.13),
          have_attributes(date: Time.local(1990, 12, 4), opening_price: 1622.65, high_price: 1668.20, low_price: 1622.65, close_price: 1622.65),
          have_attributes(date: Time.local(1990, 12, 3), opening_price: 1671.22, high_price: 1690.80, low_price: 1652.90, close_price: 1671.22),
          have_attributes(date: Time.local(1990, 11, 30), opening_price: 1652.01, high_price: 1664.17, low_price: 1622.50, close_price: 1652.01),
          have_attributes(date: Time.local(1990, 11, 29), opening_price: 1666.96, high_price: 1694.67, low_price: 1648.23, close_price: 1666.96),
          have_attributes(date: Time.local(1990, 11, 28), opening_price: 1697.35, high_price: 1737.34, low_price: 1696.23, close_price: 1697.35),
          have_attributes(date: Time.local(1990, 11, 27), opening_price: 1734.30, high_price: 1745.60, low_price: 1730.60, close_price: 1734.30),
          have_attributes(date: Time.local(1990, 11, 26), opening_price: 1747.08, high_price: 1748.61, low_price: 1729.19, close_price: 1747.08),
          have_attributes(date: Time.local(1990, 11, 22), opening_price: 1727.66, high_price: 1727.66, low_price: 1689.62, close_price: 1727.66),
          have_attributes(date: Time.local(1990, 11, 21), opening_price: 1688.53, high_price: 1717.69, low_price: 1678.51, close_price: 1688.53),
          have_attributes(date: Time.local(1990, 11, 20), opening_price: 1719.79, high_price: 1738.45, low_price: 1719.18, close_price: 1719.79),
          have_attributes(date: Time.local(1990, 11, 19), opening_price: 1740.06, high_price: 1744.71, low_price: 1722.89, close_price: 1740.06),
          have_attributes(date: Time.local(1990, 11, 16), opening_price: 1720.12, high_price: 1742.81, low_price: 1707.59, close_price: 1720.12),
          have_attributes(date: Time.local(1990, 11, 15), opening_price: 1745.87, high_price: 1773.11, low_price: 1743.68, close_price: 1745.87),
          have_attributes(date: Time.local(1990, 11, 14), opening_price: 1770.30, high_price: 1779.55, low_price: 1759.12, close_price: 1770.30),
          have_attributes(date: Time.local(1990, 11, 13), opening_price: 1773.02, high_price: 1773.04, low_price: 1708.18, close_price: 1773.02),
          have_attributes(date: Time.local(1990, 11, 9), opening_price: 1707.44, high_price: 1719.05, low_price: 1688.94, close_price: 1707.44),
          have_attributes(date: Time.local(1990, 11, 8), opening_price: 1721.91, high_price: 1749.21, low_price: 1712.36, close_price: 1721.91),
          have_attributes(date: Time.local(1990, 11, 7), opening_price: 1752.32, high_price: 1779.01, low_price: 1741.43, close_price: 1752.32),
          have_attributes(date: Time.local(1990, 11, 6), opening_price: 1781.62, high_price: 1818.64, low_price: 1774.11, close_price: 1781.62),
          have_attributes(date: Time.local(1990, 11, 5), opening_price: 1801.23, high_price: 1809.17, low_price: 1788.14, close_price: 1801.23),
          have_attributes(date: Time.local(1990, 11, 2), opening_price: 1786.38, high_price: 1795.04, low_price: 1754.51, close_price: 1786.38),
          have_attributes(date: Time.local(1990, 11, 1), opening_price: 1794.79, high_price: 1854.16, low_price: 1792.63, close_price: 1794.79),
          have_attributes(date: Time.local(1990, 10, 31), opening_price: 1856.12, high_price: 1863.00, low_price: 1853.26, close_price: 1856.12),
          have_attributes(date: Time.local(1990, 10, 30), opening_price: 1865.24, high_price: 1875.81, low_price: 1851.28, close_price: 1865.24),
          have_attributes(date: Time.local(1990, 10, 29), opening_price: 1876.07, high_price: 1879.79, low_price: 1859.98, close_price: 1876.07),
          have_attributes(date: Time.local(1990, 10, 26), opening_price: 1861.04, high_price: 1878.10, low_price: 1856.27, close_price: 1861.04),
          have_attributes(date: Time.local(1990, 10, 25), opening_price: 1880.63, high_price: 1886.54, low_price: 1844.04, close_price: 1880.63),
          have_attributes(date: Time.local(1990, 10, 24), opening_price: 1841.48, high_price: 1857.19, low_price: 1826.81, close_price: 1841.48),
          have_attributes(date: Time.local(1990, 10, 23), opening_price: 1859.56, high_price: 1874.30, low_price: 1856.30, close_price: 1859.56),
          have_attributes(date: Time.local(1990, 10, 22), opening_price: 1858.30, high_price: 1866.37, low_price: 1816.65, close_price: 1858.30),
          have_attributes(date: Time.local(1990, 10, 19), opening_price: 1816.29, high_price: 1845.35, low_price: 1785.04, close_price: 1816.29),
          have_attributes(date: Time.local(1990, 10, 18), opening_price: 1783.53, high_price: 1783.53, low_price: 1753.25, close_price: 1783.53),
          have_attributes(date: Time.local(1990, 10, 17), opening_price: 1753.34, high_price: 1761.80, low_price: 1730.72, close_price: 1753.34),
          have_attributes(date: Time.local(1990, 10, 16), opening_price: 1731.69, high_price: 1742.31, low_price: 1708.45, close_price: 1731.69),
          have_attributes(date: Time.local(1990, 10, 15), opening_price: 1706.33, high_price: 1706.33, low_price: 1665.36, close_price: 1706.33),
          have_attributes(date: Time.local(1990, 10, 12), opening_price: 1663.69, high_price: 1669.21, low_price: 1643.36, close_price: 1663.69),
          have_attributes(date: Time.local(1990, 10, 11), opening_price: 1671.68, high_price: 1726.21, low_price: 1665.39, close_price: 1671.68),
          have_attributes(date: Time.local(1990, 10, 9), opening_price: 1728.69, high_price: 1751.34, low_price: 1722.15, close_price: 1728.69),
          have_attributes(date: Time.local(1990, 10, 8), opening_price: 1727.19, high_price: 1730.93, low_price: 1682.55, close_price: 1727.19),
          have_attributes(date: Time.local(1990, 10, 5), opening_price: 1680.67, high_price: 1700.32, low_price: 1650.83, close_price: 1680.67),
          have_attributes(date: Time.local(1990, 10, 4), opening_price: 1649.52, high_price: 1668.32, low_price: 1639.31, close_price: 1649.52),
          have_attributes(date: Time.local(1990, 10, 3), opening_price: 1670.05, high_price: 1692.48, low_price: 1654.92, close_price: 1670.05),
          have_attributes(date: Time.local(1990, 10, 2), opening_price: 1668.83, high_price: 1668.98, low_price: 1523.55, close_price: 1668.83),
          have_attributes(date: Time.local(1990, 10, 1), opening_price: 1523.43, high_price: 1573.31, low_price: 1491.80, close_price: 1523.43),
          have_attributes(date: Time.local(1990, 9, 28), opening_price: 1570.95, high_price: 1619.34, low_price: 1551.01, close_price: 1570.95),
          have_attributes(date: Time.local(1990, 9, 27), opening_price: 1620.26, high_price: 1650.83, low_price: 1604.34, close_price: 1620.26),
          have_attributes(date: Time.local(1990, 9, 26), opening_price: 1651.44, high_price: 1731.01, low_price: 1651.44, close_price: 1651.44),
          have_attributes(date: Time.local(1990, 9, 25), opening_price: 1719.36, high_price: 1767.38, low_price: 1716.68, close_price: 1719.36),
          have_attributes(date: Time.local(1990, 9, 21), opening_price: 1769.77, high_price: 1769.80, low_price: 1731.32, close_price: 1769.77),
          have_attributes(date: Time.local(1990, 9, 20), opening_price: 1767.97, high_price: 1799.96, low_price: 1764.17, close_price: 1767.97),
          have_attributes(date: Time.local(1990, 9, 19), opening_price: 1799.72, high_price: 1823.96, low_price: 1799.67, close_price: 1799.72),
          have_attributes(date: Time.local(1990, 9, 18), opening_price: 1816.33, high_price: 1857.73, low_price: 1794.10, close_price: 1816.33),
          have_attributes(date: Time.local(1990, 9, 17), opening_price: 1860.19, high_price: 1893.06, low_price: 1858.10, close_price: 1860.19),
          have_attributes(date: Time.local(1990, 9, 14), opening_price: 1895.68, high_price: 1911.12, low_price: 1894.35, close_price: 1895.68),
          have_attributes(date: Time.local(1990, 9, 13), opening_price: 1912.68, high_price: 1926.19, low_price: 1903.93, close_price: 1912.68),
          have_attributes(date: Time.local(1990, 9, 12), opening_price: 1913.72, high_price: 1914.81, low_price: 1872.49, close_price: 1913.72),
          have_attributes(date: Time.local(1990, 9, 11), opening_price: 1880.70, high_price: 1902.26, low_price: 1876.44, close_price: 1880.70),
          have_attributes(date: Time.local(1990, 9, 10), opening_price: 1903.28, high_price: 1903.68, low_price: 1848.76, close_price: 1903.28),
          have_attributes(date: Time.local(1990, 9, 7), opening_price: 1845.93, high_price: 1851.59, low_price: 1819.52, close_price: 1845.93),
          have_attributes(date: Time.local(1990, 9, 6), opening_price: 1846.03, high_price: 1872.08, low_price: 1839.41, close_price: 1846.03),
          have_attributes(date: Time.local(1990, 9, 5), opening_price: 1860.08, high_price: 1909.20, low_price: 1839.54, close_price: 1860.08),
          have_attributes(date: Time.local(1990, 9, 4), opening_price: 1910.38, high_price: 1944.97, low_price: 1907.42, close_price: 1910.38),
          have_attributes(date: Time.local(1990, 9, 3), opening_price: 1945.92, high_price: 1981.61, low_price: 1945.77, close_price: 1945.92),
          have_attributes(date: Time.local(1990, 8, 31), opening_price: 1973.97, high_price: 1983.91, low_price: 1950.72, close_price: 1973.97),
          have_attributes(date: Time.local(1990, 8, 30), opening_price: 1956.02, high_price: 1956.17, low_price: 1909.84, close_price: 1956.02),
          have_attributes(date: Time.local(1990, 8, 29), opening_price: 1911.42, high_price: 1946.47, low_price: 1910.72, close_price: 1911.42),
          have_attributes(date: Time.local(1990, 8, 28), opening_price: 1947.51, high_price: 1955.56, low_price: 1905.21, close_price: 1947.51),
          have_attributes(date: Time.local(1990, 8, 27), opening_price: 1904.59, high_price: 1904.59, low_price: 1846.97, close_price: 1904.59),
          have_attributes(date: Time.local(1990, 8, 24), opening_price: 1845.72, high_price: 1877.78, low_price: 1814.59, close_price: 1845.72),
          have_attributes(date: Time.local(1990, 8, 23), opening_price: 1829.25, high_price: 1938.67, low_price: 1827.38, close_price: 1829.25),
          have_attributes(date: Time.local(1990, 8, 22), opening_price: 1939.83, high_price: 2006.68, low_price: 1925.50, close_price: 1939.83),
          have_attributes(date: Time.local(1990, 8, 21), opening_price: 2009.35, high_price: 2044.76, low_price: 2009.33, close_price: 2009.35),
          have_attributes(date: Time.local(1990, 8, 20), opening_price: 2022.98, high_price: 2037.79, low_price: 2016.38, close_price: 2022.98),
          have_attributes(date: Time.local(1990, 8, 17), opening_price: 2033.30, high_price: 2064.51, low_price: 2019.31, close_price: 2033.30),
          have_attributes(date: Time.local(1990, 8, 16), opening_price: 2067.36, high_price: 2097.28, low_price: 2065.01, close_price: 2067.36),
          have_attributes(date: Time.local(1990, 8, 15), opening_price: 2099.49, high_price: 2099.72, low_price: 2023.88, close_price: 2099.49),
          have_attributes(date: Time.local(1990, 8, 14), opening_price: 2020.33, high_price: 2026.21, low_price: 1984.63, close_price: 2020.33),
          have_attributes(date: Time.local(1990, 8, 13), opening_price: 1993.04, high_price: 2053.02, low_price: 1984.29, close_price: 1993.04),
          have_attributes(date: Time.local(1990, 8, 10), opening_price: 2056.88, high_price: 2084.26, low_price: 2047.74, close_price: 2056.88),
          have_attributes(date: Time.local(1990, 8, 9), opening_price: 2068.41, high_price: 2099.47, low_price: 2068.41, close_price: 2068.41),
          have_attributes(date: Time.local(1990, 8, 8), opening_price: 2100.02, high_price: 2101.55, low_price: 2047.48, close_price: 2100.02),
          have_attributes(date: Time.local(1990, 8, 7), opening_price: 2046.42, high_price: 2096.94, low_price: 2015.01, close_price: 2046.42),
          have_attributes(date: Time.local(1990, 8, 6), opening_price: 2098.53, high_price: 2171.85, low_price: 2088.34, close_price: 2098.53),
          have_attributes(date: Time.local(1990, 8, 3), opening_price: 2174.67, high_price: 2213.41, low_price: 2173.69, close_price: 2174.67),
          have_attributes(date: Time.local(1990, 8, 2), opening_price: 2215.43, high_price: 2244.06, low_price: 2198.87, close_price: 2215.43),
          have_attributes(date: Time.local(1990, 8, 1), opening_price: 2246.68, high_price: 2278.89, low_price: 2239.16, close_price: 2246.68),
          have_attributes(date: Time.local(1990, 7, 31), opening_price: 2252.56, high_price: 2252.87, low_price: 2228.83, close_price: 2252.56),
          have_attributes(date: Time.local(1990, 7, 30), opening_price: 2225.29, high_price: 2248.37, low_price: 2219.84, close_price: 2225.29),
          have_attributes(date: Time.local(1990, 7, 27), opening_price: 2249.26, high_price: 2279.69, low_price: 2224.51, close_price: 2249.26),
          have_attributes(date: Time.local(1990, 7, 26), opening_price: 2281.20, high_price: 2311.27, low_price: 2278.77, close_price: 2281.20),
          have_attributes(date: Time.local(1990, 7, 25), opening_price: 2307.31, high_price: 2318.25, low_price: 2304.61, close_price: 2307.31),
          have_attributes(date: Time.local(1990, 7, 24), opening_price: 2304.59, high_price: 2325.07, low_price: 2299.27, close_price: 2304.59),
          have_attributes(date: Time.local(1990, 7, 23), opening_price: 2329.92, high_price: 2363.76, low_price: 2326.04, close_price: 2329.92),
          have_attributes(date: Time.local(1990, 7, 20), opening_price: 2363.43, high_price: 2390.88, low_price: 2363.36, close_price: 2363.43),
          have_attributes(date: Time.local(1990, 7, 19), opening_price: 2393.08, high_price: 2398.27, low_price: 2384.19, close_price: 2393.08),
          have_attributes(date: Time.local(1990, 7, 18), opening_price: 2397.78, high_price: 2411.38, low_price: 2395.05, close_price: 2397.78),
          have_attributes(date: Time.local(1990, 7, 17), opening_price: 2407.31, high_price: 2411.20, low_price: 2397.16, close_price: 2407.31),
          have_attributes(date: Time.local(1990, 7, 16), opening_price: 2400.16, high_price: 2400.16, low_price: 2371.47, close_price: 2400.16),
          have_attributes(date: Time.local(1990, 7, 13), opening_price: 2369.84, high_price: 2372.06, low_price: 2356.78, close_price: 2369.84),
          have_attributes(date: Time.local(1990, 7, 12), opening_price: 2365.21, high_price: 2367.34, low_price: 2356.78, close_price: 2365.21),
          have_attributes(date: Time.local(1990, 7, 11), opening_price: 2351.57, high_price: 2353.73, low_price: 2336.51, close_price: 2351.57),
          have_attributes(date: Time.local(1990, 7, 10), opening_price: 2337.77, high_price: 2364.01, low_price: 2337.62, close_price: 2337.77),
          have_attributes(date: Time.local(1990, 7, 9), opening_price: 2362.41, high_price: 2366.24, low_price: 2357.84, close_price: 2362.41),
          have_attributes(date: Time.local(1990, 7, 6), opening_price: 2364.20, high_price: 2364.20, low_price: 2357.13, close_price: 2364.20),
          have_attributes(date: Time.local(1990, 7, 5), opening_price: 2362.04, high_price: 2369.85, low_price: 2360.27, close_price: 2362.04),
          have_attributes(date: Time.local(1990, 7, 4), opening_price: 2363.35, high_price: 2371.03, low_price: 2350.65, close_price: 2363.35),
          have_attributes(date: Time.local(1990, 7, 3), opening_price: 2349.48, high_price: 2356.28, low_price: 2343.34, close_price: 2349.48),
          have_attributes(date: Time.local(1990, 7, 2), opening_price: 2348.70, high_price: 2348.70, low_price: 2335.70, close_price: 2348.70),
          have_attributes(date: Time.local(1990, 6, 29), opening_price: 2343.36, high_price: 2364.70, low_price: 2343.36, close_price: 2343.36),
          have_attributes(date: Time.local(1990, 6, 28), opening_price: 2350.40, high_price: 2367.84, low_price: 2343.83, close_price: 2350.40),
          have_attributes(date: Time.local(1990, 6, 27), opening_price: 2362.40, high_price: 2362.40, low_price: 2325.84, close_price: 2362.40),
          have_attributes(date: Time.local(1990, 6, 26), opening_price: 2323.35, high_price: 2323.41, low_price: 2300.53, close_price: 2323.35),
          have_attributes(date: Time.local(1990, 6, 25), opening_price: 2301.02, high_price: 2337.29, low_price: 2299.67, close_price: 2301.02),
          have_attributes(date: Time.local(1990, 6, 22), opening_price: 2341.06, high_price: 2359.38, low_price: 2337.02, close_price: 2341.06),
          have_attributes(date: Time.local(1990, 6, 21), opening_price: 2361.56, high_price: 2376.92, low_price: 2355.85, close_price: 2361.56),
          have_attributes(date: Time.local(1990, 6, 20), opening_price: 2366.80, high_price: 2367.45, low_price: 2353.63, close_price: 2366.80),
          have_attributes(date: Time.local(1990, 6, 19), opening_price: 2353.93, high_price: 2372.25, low_price: 2353.55, close_price: 2353.93),
          have_attributes(date: Time.local(1990, 6, 18), opening_price: 2381.03, high_price: 2396.69, low_price: 2378.21, close_price: 2381.03),
          have_attributes(date: Time.local(1990, 6, 15), opening_price: 2396.32, high_price: 2402.64, low_price: 2392.83, close_price: 2396.32),
          have_attributes(date: Time.local(1990, 6, 14), opening_price: 2399.97, high_price: 2399.99, low_price: 2381.41, close_price: 2399.97),
          have_attributes(date: Time.local(1990, 6, 13), opening_price: 2378.41, high_price: 2388.04, low_price: 2372.91, close_price: 2378.41),
          have_attributes(date: Time.local(1990, 6, 12), opening_price: 2380.56, high_price: 2392.91, low_price: 2378.69, close_price: 2380.56),
          have_attributes(date: Time.local(1990, 6, 11), opening_price: 2393.01, high_price: 2410.30, low_price: 2389.47, close_price: 2393.01),
          have_attributes(date: Time.local(1990, 6, 8), opening_price: 2411.78, high_price: 2427.74, low_price: 2407.26, close_price: 2411.78),
          have_attributes(date: Time.local(1990, 6, 7), opening_price: 2428.44, high_price: 2431.35, low_price: 2424.47, close_price: 2428.44),
          have_attributes(date: Time.local(1990, 6, 6), opening_price: 2423.07, high_price: 2429.05, low_price: 2418.32, close_price: 2423.07),
          have_attributes(date: Time.local(1990, 6, 5), opening_price: 2432.31, high_price: 2436.07, low_price: 2427.94, close_price: 2432.31),
          have_attributes(date: Time.local(1990, 6, 4), opening_price: 2427.24, high_price: 2435.00, low_price: 2426.92, close_price: 2427.24),
          have_attributes(date: Time.local(1990, 6, 1), opening_price: 2426.55, high_price: 2434.89, low_price: 2422.10, close_price: 2426.55),
          have_attributes(date: Time.local(1990, 5, 31), opening_price: 2435.74, high_price: 2435.74, low_price: 2418.76, close_price: 2435.74),
          have_attributes(date: Time.local(1990, 5, 30), opening_price: 2417.09, high_price: 2419.73, low_price: 2400.07, close_price: 2417.09),
          have_attributes(date: Time.local(1990, 5, 29), opening_price: 2411.66, high_price: 2434.10, low_price: 2409.79, close_price: 2411.66),
          have_attributes(date: Time.local(1990, 5, 28), opening_price: 2434.05, high_price: 2440.75, low_price: 2421.08, close_price: 2434.05),
          have_attributes(date: Time.local(1990, 5, 25), opening_price: 2419.94, high_price: 2422.24, low_price: 2396.89, close_price: 2419.94),
          have_attributes(date: Time.local(1990, 5, 24), opening_price: 2395.90, high_price: 2401.12, low_price: 2382.89, close_price: 2395.90),
          have_attributes(date: Time.local(1990, 5, 23), opening_price: 2394.95, high_price: 2402.98, low_price: 2392.39, close_price: 2394.95),
          have_attributes(date: Time.local(1990, 5, 22), opening_price: 2390.59, high_price: 2390.59, low_price: 2365.93, close_price: 2390.59),
          have_attributes(date: Time.local(1990, 5, 21), opening_price: 2370.55, high_price: 2386.78, low_price: 2365.94, close_price: 2370.55),
          have_attributes(date: Time.local(1990, 5, 18), opening_price: 2388.26, high_price: 2405.29, low_price: 2383.13, close_price: 2388.26),
          have_attributes(date: Time.local(1990, 5, 17), opening_price: 2399.23, high_price: 2406.82, low_price: 2399.01, close_price: 2399.23),
          have_attributes(date: Time.local(1990, 5, 16), opening_price: 2403.77, high_price: 2410.86, low_price: 2395.51, close_price: 2403.77),
          have_attributes(date: Time.local(1990, 5, 15), opening_price: 2398.78, high_price: 2409.39, low_price: 2390.50, close_price: 2398.78),
          have_attributes(date: Time.local(1990, 5, 14), opening_price: 2390.32, high_price: 2390.32, low_price: 2351.14, close_price: 2390.32),
          have_attributes(date: Time.local(1990, 5, 11), opening_price: 2348.97, high_price: 2348.97, low_price: 2314.15, close_price: 2348.97),
          have_attributes(date: Time.local(1990, 5, 10), opening_price: 2312.85, high_price: 2323.53, low_price: 2309.64, close_price: 2312.85),
          have_attributes(date: Time.local(1990, 5, 9), opening_price: 2308.79, high_price: 2314.89, low_price: 2300.44, close_price: 2308.79),
          have_attributes(date: Time.local(1990, 5, 8), opening_price: 2303.60, high_price: 2305.13, low_price: 2286.80, close_price: 2303.60),
          have_attributes(date: Time.local(1990, 5, 7), opening_price: 2296.49, high_price: 2296.50, low_price: 2250.78, close_price: 2296.49),
          have_attributes(date: Time.local(1990, 5, 2), opening_price: 2247.81, high_price: 2247.81, low_price: 2216.93, close_price: 2247.81),
          have_attributes(date: Time.local(1990, 5, 1), opening_price: 2214.78, high_price: 2214.82, low_price: 2201.06, close_price: 2214.78),
          have_attributes(date: Time.local(1990, 4, 27), opening_price: 2205.96, high_price: 2206.98, low_price: 2195.87, close_price: 2205.96),
          have_attributes(date: Time.local(1990, 4, 26), opening_price: 2200.10, high_price: 2207.21, low_price: 2198.23, close_price: 2200.10),
          have_attributes(date: Time.local(1990, 4, 25), opening_price: 2200.51, high_price: 2210.07, low_price: 2193.05, close_price: 2200.51),
          have_attributes(date: Time.local(1990, 4, 24), opening_price: 2193.09, high_price: 2197.75, low_price: 2179.21, close_price: 2193.09),
          have_attributes(date: Time.local(1990, 4, 23), opening_price: 2201.20, high_price: 2219.45, low_price: 2193.24, close_price: 2201.20),
          have_attributes(date: Time.local(1990, 4, 20), opening_price: 2214.16, high_price: 2228.69, low_price: 2202.87, close_price: 2214.16),
          have_attributes(date: Time.local(1990, 4, 19), opening_price: 2213.49, high_price: 2217.62, low_price: 2171.42, close_price: 2213.49),
          have_attributes(date: Time.local(1990, 4, 18), opening_price: 2167.96, high_price: 2168.12, low_price: 2127.26, close_price: 2167.96),
          have_attributes(date: Time.local(1990, 4, 17), opening_price: 2128.57, high_price: 2148.99, low_price: 2123.53, close_price: 2128.57),
          have_attributes(date: Time.local(1990, 4, 16), opening_price: 2129.77, high_price: 2162.68, low_price: 2123.44, close_price: 2129.77),
          have_attributes(date: Time.local(1990, 4, 13), opening_price: 2165.89, high_price: 2181.08, low_price: 2158.32, close_price: 2165.89),
          have_attributes(date: Time.local(1990, 4, 12), opening_price: 2183.34, high_price: 2196.54, low_price: 2167.36, close_price: 2183.34),
          have_attributes(date: Time.local(1990, 4, 11), opening_price: 2185.30, high_price: 2212.52, low_price: 2181.07, close_price: 2185.30),
          have_attributes(date: Time.local(1990, 4, 10), opening_price: 2186.24, high_price: 2186.24, low_price: 2186.24, close_price: 2186.24),
          have_attributes(date: Time.local(1990, 4, 9), opening_price: 2229.27, high_price: 2232.59, low_price: 2151.40, close_price: 2229.27),
          have_attributes(date: Time.local(1990, 4, 6), opening_price: 2149.26, high_price: 2149.26, low_price: 2060.40, close_price: 2149.26),
          have_attributes(date: Time.local(1990, 4, 5), opening_price: 2058.82, high_price: 2074.85, low_price: 2001.15, close_price: 2058.82),
          have_attributes(date: Time.local(1990, 4, 4), opening_price: 2113.14, high_price: 2113.14, low_price: 2112.28, close_price: 2113.14),
          have_attributes(date: Time.local(1990, 4, 3), opening_price: 2111.11, high_price: 2113.56, low_price: 2054.70, close_price: 2111.11),
          have_attributes(date: Time.local(1990, 4, 2), opening_price: 2069.33, high_price: 2226.95, low_price: 2069.33, close_price: 2069.33),
          have_attributes(date: Time.local(1990, 3, 30), opening_price: 2227.48, high_price: 2285.12, low_price: 2221.65, close_price: 2227.48),
          have_attributes(date: Time.local(1990, 3, 29), opening_price: 2286.85, high_price: 2310.94, low_price: 2279.46, close_price: 2286.85),
          have_attributes(date: Time.local(1990, 3, 28), opening_price: 2306.85, high_price: 2337.76, low_price: 2293.99, close_price: 2306.85),
          have_attributes(date: Time.local(1990, 3, 27), opening_price: 2339.08, high_price: 2351.94, low_price: 2307.43, close_price: 2339.08),
          have_attributes(date: Time.local(1990, 3, 26), opening_price: 2313.63, high_price: 2313.63, low_price: 2208.35, close_price: 2313.63),
          have_attributes(date: Time.local(1990, 3, 23), opening_price: 2206.99, high_price: 2206.99, low_price: 2165.75, close_price: 2206.99),
          have_attributes(date: Time.local(1990, 3, 22), opening_price: 2173.17, high_price: 2271.99, low_price: 2133.48, close_price: 2173.17),
          have_attributes(date: Time.local(1990, 3, 20), opening_price: 2273.18, high_price: 2334.62, low_price: 2261.05, close_price: 2273.18),
          have_attributes(date: Time.local(1990, 3, 19), opening_price: 2326.23, high_price: 2419.89, low_price: 2322.43, close_price: 2326.23),
          have_attributes(date: Time.local(1990, 3, 16), opening_price: 2419.21, high_price: 2445.49, low_price: 2412.37, close_price: 2419.21),
          have_attributes(date: Time.local(1990, 3, 15), opening_price: 2427.64, high_price: 2431.53, low_price: 2421.54, close_price: 2427.64),
          have_attributes(date: Time.local(1990, 3, 14), opening_price: 2420.70, high_price: 2454.19, low_price: 2419.17, close_price: 2420.70),
          have_attributes(date: Time.local(1990, 3, 13), opening_price: 2457.10, high_price: 2504.42, low_price: 2457.10, close_price: 2457.10),
          have_attributes(date: Time.local(1990, 3, 12), opening_price: 2508.88, high_price: 2540.65, low_price: 2507.25, close_price: 2508.88),
          have_attributes(date: Time.local(1990, 3, 9), opening_price: 2539.89, high_price: 2553.68, low_price: 2538.26, close_price: 2539.89),
          have_attributes(date: Time.local(1990, 3, 8), opening_price: 2536.54, high_price: 2542.24, low_price: 2496.14, close_price: 2536.54),
          have_attributes(date: Time.local(1990, 3, 7), opening_price: 2516.27, high_price: 2536.16, low_price: 2507.04, close_price: 2516.27),
          have_attributes(date: Time.local(1990, 3, 6), opening_price: 2536.37, high_price: 2550.10, low_price: 2533.05, close_price: 2536.37),
          have_attributes(date: Time.local(1990, 3, 5), opening_price: 2535.48, high_price: 2544.60, low_price: 2532.35, close_price: 2535.48),
          have_attributes(date: Time.local(1990, 3, 2), opening_price: 2541.97, high_price: 2549.52, low_price: 2530.12, close_price: 2541.97),
          have_attributes(date: Time.local(1990, 3, 1), opening_price: 2536.01, high_price: 2565.37, low_price: 2536.01, close_price: 2536.01),
          have_attributes(date: Time.local(1990, 2, 28), opening_price: 2565.54, high_price: 2571.20, low_price: 2503.21, close_price: 2565.54),
          have_attributes(date: Time.local(1990, 2, 27), opening_price: 2500.04, high_price: 2500.04, low_price: 2435.61, close_price: 2500.04),
          have_attributes(date: Time.local(1990, 2, 26), opening_price: 2448.31, high_price: 2551.00, low_price: 2395.12, close_price: 2448.31),
          have_attributes(date: Time.local(1990, 2, 23), opening_price: 2554.31, high_price: 2613.72, low_price: 2549.23, close_price: 2554.31),
          have_attributes(date: Time.local(1990, 2, 22), opening_price: 2615.09, high_price: 2640.95, low_price: 2581.77, close_price: 2615.09),
          have_attributes(date: Time.local(1990, 2, 21), opening_price: 2620.21, high_price: 2692.84, low_price: 2620.21, close_price: 2620.21),
          have_attributes(date: Time.local(1990, 2, 20), opening_price: 2696.08, high_price: 2713.80, low_price: 2694.51, close_price: 2696.08),
          have_attributes(date: Time.local(1990, 2, 19), opening_price: 2718.56, high_price: 2758.35, low_price: 2715.11, close_price: 2718.56),
          have_attributes(date: Time.local(1990, 2, 16), opening_price: 2746.05, high_price: 2758.40, low_price: 2741.87, close_price: 2746.05),
          have_attributes(date: Time.local(1990, 2, 15), opening_price: 2746.25, high_price: 2746.25, low_price: 2725.43, close_price: 2746.25),
          have_attributes(date: Time.local(1990, 2, 14), opening_price: 2723.30, high_price: 2723.46, low_price: 2717.34, close_price: 2723.30),
          have_attributes(date: Time.local(1990, 2, 13), opening_price: 2722.33, high_price: 2734.69, low_price: 2721.17, close_price: 2722.33),
          have_attributes(date: Time.local(1990, 2, 9), opening_price: 2734.17, high_price: 2745.12, low_price: 2728.87, close_price: 2734.17),
          have_attributes(date: Time.local(1990, 2, 8), opening_price: 2753.40, high_price: 2756.98, low_price: 2752.33, close_price: 2753.40),
          have_attributes(date: Time.local(1990, 2, 7), opening_price: 2750.36, high_price: 2757.88, low_price: 2744.80, close_price: 2750.36),
          have_attributes(date: Time.local(1990, 2, 6), opening_price: 2766.13, high_price: 2774.32, low_price: 2765.57, close_price: 2766.13),
          have_attributes(date: Time.local(1990, 2, 5), opening_price: 2763.11, high_price: 2769.07, low_price: 2757.89, close_price: 2763.11),
          have_attributes(date: Time.local(1990, 2, 2), opening_price: 2762.40, high_price: 2762.40, low_price: 2754.57, close_price: 2762.40),
          have_attributes(date: Time.local(1990, 2, 1), opening_price: 2754.09, high_price: 2754.09, low_price: 2740.60, close_price: 2754.09),
          have_attributes(date: Time.local(1990, 1, 31), opening_price: 2737.57, high_price: 2739.50, low_price: 2725.40, close_price: 2737.57),
          have_attributes(date: Time.local(1990, 1, 30), opening_price: 2741.22, high_price: 2750.15, low_price: 2739.39, close_price: 2741.22),
          have_attributes(date: Time.local(1990, 1, 29), opening_price: 2736.76, high_price: 2739.15, low_price: 2712.64, close_price: 2736.76),
          have_attributes(date: Time.local(1990, 1, 26), opening_price: 2711.15, high_price: 2726.14, low_price: 2706.97, close_price: 2711.15),
          have_attributes(date: Time.local(1990, 1, 25), opening_price: 2712.90, high_price: 2720.71, low_price: 2707.36, close_price: 2712.90),
          have_attributes(date: Time.local(1990, 1, 24), opening_price: 2705.46, high_price: 2747.65, low_price: 2705.35, close_price: 2705.46),
          have_attributes(date: Time.local(1990, 1, 23), opening_price: 2740.18, high_price: 2740.18, low_price: 2721.18, close_price: 2740.18),
          have_attributes(date: Time.local(1990, 1, 22), opening_price: 2735.85, high_price: 2735.85, low_price: 2703.74, close_price: 2735.85),
          have_attributes(date: Time.local(1990, 1, 19), opening_price: 2701.31, high_price: 2702.18, low_price: 2680.76, close_price: 2701.31),
          have_attributes(date: Time.local(1990, 1, 18), opening_price: 2705.41, high_price: 2722.97, low_price: 2698.40, close_price: 2705.41),
          have_attributes(date: Time.local(1990, 1, 17), opening_price: 2719.48, high_price: 2745.05, low_price: 2719.48, close_price: 2719.48),
          have_attributes(date: Time.local(1990, 1, 16), opening_price: 2723.88, high_price: 2782.82, low_price: 2716.87, close_price: 2723.88),
          have_attributes(date: Time.local(1990, 1, 12), opening_price: 2786.47, high_price: 2811.37, low_price: 2786.47, close_price: 2786.47),
          have_attributes(date: Time.local(1990, 1, 11), opening_price: 2814.13, high_price: 2814.13, low_price: 2790.35, close_price: 2814.13),
          have_attributes(date: Time.local(1990, 1, 10), opening_price: 2793.80, high_price: 2815.21, low_price: 2789.02, close_price: 2793.80),
          have_attributes(date: Time.local(1990, 1, 9), opening_price: 2817.24, high_price: 2837.13, low_price: 2806.21, close_price: 2817.24),
          have_attributes(date: Time.local(1990, 1, 8), opening_price: 2832.20, high_price: 2854.85, low_price: 2825.00, close_price: 2832.20),
          have_attributes(date: Time.local(1990, 1, 5), opening_price: 2834.61, high_price: 2872.24, low_price: 2824.58, close_price: 2834.61),
          have_attributes(date: Time.local(1990, 1, 4), opening_price: 2867.70, high_price: 2884.79, low_price: 2866.69, close_price: 2867.70),
        ])
      end
    end

    context "2019s" do
      it "is indexes" do
        context = {}
  
        @parser_2019.parse(context)
  
        expect(context).to be_empty

        expect(InvestmentMachine::Model::Topix.all).to match_array([
          have_attributes(date: Time.local(2019, 4, 2), opening_price: 1632.03, high_price: 1632.03, low_price: 1611.26, close_price: 1611.69),
          have_attributes(date: Time.local(2019, 4, 1), opening_price: 1612.13, high_price: 1624.43, low_price: 1611.71, close_price: 1615.81),
          have_attributes(date: Time.local(2019, 3, 29), opening_price: 1595.58, high_price: 1597.66, low_price: 1588.12, close_price: 1591.64),
          have_attributes(date: Time.local(2019, 3, 28), opening_price: 1595.09, high_price: 1595.62, low_price: 1577.15, close_price: 1582.85),
          have_attributes(date: Time.local(2019, 3, 27), opening_price: 1606.78, high_price: 1610.17, low_price: 1598.10, close_price: 1609.49),
          have_attributes(date: Time.local(2019, 3, 26), opening_price: 1592.59, high_price: 1618.40, low_price: 1591.79, close_price: 1617.94),
          have_attributes(date: Time.local(2019, 3, 25), opening_price: 1593.30, high_price: 1593.40, low_price: 1571.74, close_price: 1577.41),
          have_attributes(date: Time.local(2019, 3, 22), opening_price: 1617.38, high_price: 1618.14, low_price: 1610.09, close_price: 1617.11),
          have_attributes(date: Time.local(2019, 3, 20), opening_price: 1609.30, high_price: 1614.60, low_price: 1607.99, close_price: 1614.39),
          have_attributes(date: Time.local(2019, 3, 19), opening_price: 1612.36, high_price: 1612.36, low_price: 1601.73, close_price: 1610.23),
          have_attributes(date: Time.local(2019, 3, 18), opening_price: 1610.74, high_price: 1613.69, low_price: 1604.47, close_price: 1613.68),
          have_attributes(date: Time.local(2019, 3, 15), opening_price: 1595.02, high_price: 1607.10, low_price: 1594.39, close_price: 1602.63),
          have_attributes(date: Time.local(2019, 3, 14), opening_price: 1603.32, high_price: 1606.37, low_price: 1588.29, close_price: 1588.29),
          have_attributes(date: Time.local(2019, 3, 13), opening_price: 1600.73, high_price: 1604.58, low_price: 1585.79, close_price: 1592.07),
          have_attributes(date: Time.local(2019, 3, 12), opening_price: 1596.40, high_price: 1612.08, low_price: 1595.92, close_price: 1605.48),
          have_attributes(date: Time.local(2019, 3, 11), opening_price: 1574.31, high_price: 1582.72, low_price: 1570.58, close_price: 1581.44),
          have_attributes(date: Time.local(2019, 3, 8), opening_price: 1588.15, high_price: 1590.56, low_price: 1570.39, close_price: 1572.44),
          have_attributes(date: Time.local(2019, 3, 7), opening_price: 1604.85, high_price: 1605.92, low_price: 1597.42, close_price: 1601.66),
          have_attributes(date: Time.local(2019, 3, 6), opening_price: 1617.00, high_price: 1617.39, low_price: 1612.28, close_price: 1615.25),
          have_attributes(date: Time.local(2019, 3, 5), opening_price: 1618.35, high_price: 1621.79, low_price: 1612.78, close_price: 1619.23),
          have_attributes(date: Time.local(2019, 3, 4), opening_price: 1629.43, high_price: 1629.88, low_price: 1622.38, close_price: 1627.59),
          have_attributes(date: Time.local(2019, 3, 1), opening_price: 1612.47, high_price: 1618.71, low_price: 1611.00, close_price: 1615.72),
          have_attributes(date: Time.local(2019, 2, 28), opening_price: 1618.20, high_price: 1618.20, low_price: 1606.98, close_price: 1607.66),
          have_attributes(date: Time.local(2019, 2, 27), opening_price: 1619.40, high_price: 1623.37, low_price: 1619.38, close_price: 1620.42),
          have_attributes(date: Time.local(2019, 2, 26), opening_price: 1622.33, high_price: 1624.42, low_price: 1612.23, close_price: 1617.20),
          have_attributes(date: Time.local(2019, 2, 25), opening_price: 1619.61, high_price: 1623.13, low_price: 1616.94, close_price: 1620.87),
          have_attributes(date: Time.local(2019, 2, 22), opening_price: 1605.99, high_price: 1610.63, low_price: 1603.02, close_price: 1609.52),
          have_attributes(date: Time.local(2019, 2, 21), opening_price: 1612.88, high_price: 1619.57, low_price: 1605.05, close_price: 1613.50),
          have_attributes(date: Time.local(2019, 2, 20), opening_price: 1609.72, high_price: 1617.10, low_price: 1605.96, close_price: 1613.47),
          have_attributes(date: Time.local(2019, 2, 19), opening_price: 1599.65, high_price: 1607.16, low_price: 1599.16, close_price: 1606.52),
          have_attributes(date: Time.local(2019, 2, 18), opening_price: 1599.33, high_price: 1603.22, low_price: 1596.08, close_price: 1601.96),
          have_attributes(date: Time.local(2019, 2, 15), opening_price: 1580.00, high_price: 1580.79, low_price: 1569.22, close_price: 1577.29),
          have_attributes(date: Time.local(2019, 2, 14), opening_price: 1589.43, high_price: 1596.28, low_price: 1586.90, close_price: 1589.81),
          have_attributes(date: Time.local(2019, 2, 13), opening_price: 1582.64, high_price: 1591.72, low_price: 1578.09, close_price: 1589.33),
          have_attributes(date: Time.local(2019, 2, 12), opening_price: 1547.56, high_price: 1575.52, low_price: 1545.28, close_price: 1572.60),
          have_attributes(date: Time.local(2019, 2, 8), opening_price: 1552.70, high_price: 1553.39, low_price: 1536.65, close_price: 1539.40),
          have_attributes(date: Time.local(2019, 2, 7), opening_price: 1577.35, high_price: 1578.52, low_price: 1563.30, close_price: 1569.03),
          have_attributes(date: Time.local(2019, 2, 6), opening_price: 1587.49, high_price: 1591.59, low_price: 1580.88, close_price: 1582.13),
          have_attributes(date: Time.local(2019, 2, 5), opening_price: 1588.24, high_price: 1589.71, low_price: 1580.41, close_price: 1582.88),
          have_attributes(date: Time.local(2019, 2, 4), opening_price: 1570.36, high_price: 1583.04, low_price: 1570.36, close_price: 1581.33),
          have_attributes(date: Time.local(2019, 2, 1), opening_price: 1565.63, high_price: 1576.02, low_price: 1562.88, close_price: 1564.63),
          have_attributes(date: Time.local(2019, 1, 31), opening_price: 1570.63, high_price: 1574.76, low_price: 1561.12, close_price: 1567.49),
          have_attributes(date: Time.local(2019, 1, 30), opening_price: 1559.22, high_price: 1559.95, low_price: 1549.62, close_price: 1550.76),
          have_attributes(date: Time.local(2019, 1, 29), opening_price: 1548.46, high_price: 1559.19, low_price: 1541.66, close_price: 1557.09),
          have_attributes(date: Time.local(2019, 1, 28), opening_price: 1563.61, high_price: 1564.93, low_price: 1554.66, close_price: 1555.51),
          have_attributes(date: Time.local(2019, 1, 25), opening_price: 1553.49, high_price: 1570.88, low_price: 1553.43, close_price: 1566.10),
          have_attributes(date: Time.local(2019, 1, 24), opening_price: 1540.72, high_price: 1552.77, low_price: 1538.04, close_price: 1552.60),
          have_attributes(date: Time.local(2019, 1, 23), opening_price: 1545.56, high_price: 1556.45, low_price: 1543.44, close_price: 1547.03),
          have_attributes(date: Time.local(2019, 1, 22), opening_price: 1570.29, high_price: 1572.28, low_price: 1552.91, close_price: 1556.43),
          have_attributes(date: Time.local(2019, 1, 21), opening_price: 1572.94, high_price: 1574.86, low_price: 1563.79, close_price: 1566.37),
          have_attributes(date: Time.local(2019, 1, 18), opening_price: 1547.09, high_price: 1562.64, low_price: 1546.83, close_price: 1557.59),
          have_attributes(date: Time.local(2019, 1, 17), opening_price: 1546.48, high_price: 1549.42, low_price: 1537.83, close_price: 1543.20),
          have_attributes(date: Time.local(2019, 1, 16), opening_price: 1543.17, high_price: 1543.44, low_price: 1529.85, close_price: 1537.77),
          have_attributes(date: Time.local(2019, 1, 15), opening_price: 1521.83, high_price: 1544.78, low_price: 1518.75, close_price: 1542.72),
          have_attributes(date: Time.local(2019, 1, 11), opening_price: 1531.72, high_price: 1535.03, low_price: 1525.84, close_price: 1529.73),
          have_attributes(date: Time.local(2019, 1, 10), opening_price: 1523.01, high_price: 1527.82, low_price: 1514.72, close_price: 1522.01),
          have_attributes(date: Time.local(2019, 1, 9), opening_price: 1533.20, high_price: 1539.47, low_price: 1531.44, close_price: 1535.11),
          have_attributes(date: Time.local(2019, 1, 8), opening_price: 1520.93, high_price: 1529.80, low_price: 1515.23, close_price: 1518.43),
          have_attributes(date: Time.local(2019, 1, 7), opening_price: 1499.42, high_price: 1521.48, low_price: 1497.97, close_price: 1512.53),
          have_attributes(date: Time.local(2019, 1, 4), opening_price: 1468.42, high_price: 1473.11, low_price: 1446.48, close_price: 1471.16),
        ])
      end
    end
  end
end

