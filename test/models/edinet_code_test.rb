require 'test_helper'
require 'digest/md5'

class EdinetCodeTest < ActiveSupport::TestCase

  def setup
    @bucket = Stock._get_s3_bucket
    @bucket.objects.batch_delete!
  end

  test "download edinet code list" do
    # precondition
    assert_equal 0, EdinetCode.all.length

    # execute 1
    result = EdinetCode.download_edinet_code_list

    # postcondition 1
    assert result[:data].length > 0
    assert result[:edinet_codes].length > 9000

    result[:edinet_codes].each do |edinet_code|
      assert edinet_code.instance_of?(EdinetCode)
      assert edinet_code.valid?
    end

    assert_equal 0, EdinetCode.all.length

    # execute 2
    object_keys = EdinetCode.put_edinet_code_list(result[:data])

    # postcondition 2
    assert_equal "edinet_code_list.zip", object_keys[:original]
    assert_match /^edinet_code_list\.zip\.bak_[0-9]{8}-[0-9]{6}$/, object_keys[:backup]
    assert @bucket.object(object_keys[:original]).exists?
    assert @bucket.object(object_keys[:backup]).exists?

    assert_equal 0, EdinetCode.all.length

    # execute 3
    edinet_code_ids = EdinetCode.import(result[:edinet_codes])

    # postcondition 3
    assert_equal result[:edinet_codes].length, edinet_code_ids.length
    assert_equal result[:edinet_codes].length, EdinetCode.all.length
  end

  test "parse edinet code list" do
    # precondition
    zip_file_path = Rails.root.join("test", "fixtures", "files", "edinet_code", "Edinetcode_20180711_short.zip")
    zip = File.open(zip_file_path).read

    # execute
    edinet_codes = EdinetCode.parse_edinet_code_list(zip)

    # postcondition
    assert_equal 10, edinet_codes.length

    edinet_code = edinet_codes[0]
    assert_equal "E00004", edinet_code.edinet_code
    assert_equal "内国法人・組合", edinet_code.submitter_type
    assert_equal "上場", edinet_code.listed
    assert_equal "有", edinet_code.consolidated
    assert_equal 1491, edinet_code.capital
    assert_equal " 5月31日", edinet_code.settlement_date
    assert_equal "カネコ種苗株式会社", edinet_code.submitter_name
    assert_equal "KANEKO SEEDS CO., LTD.", edinet_code.submitter_name_en
    assert_equal "カネコシュビョウカブシキガイシャ", edinet_code.submitter_name_yomi
    assert_equal "前橋市古市町一丁目５０番地１２", edinet_code.address
    assert_equal "水産・農林業", edinet_code.industry
    assert_equal "13760", edinet_code.ticker_symbol
    assert_equal "5070001000715", edinet_code.corporate_number

    edinet_code = edinet_codes[4]
    assert_equal "E06360", edinet_code.edinet_code
    assert_equal "個人（組合発行者を除く）", edinet_code.submitter_type
    assert_nil edinet_code.listed
    assert_nil edinet_code.consolidated
    assert_nil edinet_code.capital
    assert_nil edinet_code.settlement_date
    assert_equal "青景　研治", edinet_code.submitter_name
    assert_nil edinet_code.submitter_name_en
    assert_equal "アオカゲ　ケンジ", edinet_code.submitter_name_yomi
    assert_nil edinet_code.address
    assert_equal "個人（組合発行者を除く）", edinet_code.industry
    assert_nil edinet_code.ticker_symbol
    assert_nil edinet_code.corporate_number

    edinet_code = edinet_codes[9]
    assert_equal "E34229", edinet_code.edinet_code
    assert_equal "内国法人・組合（有価証券報告書等の提出義務者以外）", edinet_code.submitter_type
    assert_nil edinet_code.listed
    assert_nil edinet_code.consolidated
    assert_equal 100, edinet_code.capital
    assert_nil edinet_code.settlement_date
    assert_equal "株式会社トラストシステム", edinet_code.submitter_name
    assert_nil edinet_code.submitter_name_en
    assert_equal "カブシキガイシャトラストシステム", edinet_code.submitter_name_yomi
    assert_equal "千代田区外神田４−１４−１秋葉原ＵＤＸ８階", edinet_code.address
    assert_equal "内国法人・組合（有価証券報告書等の提出義務者以外）", edinet_code.industry
    assert_nil edinet_code.ticker_symbol
    assert_equal "7010001086832", edinet_code.corporate_number
  end

  test "put and get edinet code list zip" do
    # precondition
    zip_file_path = Rails.root.join("test", "fixtures", "files", "edinet_code", "Edinetcode_20180711_short.zip")
    zip = File.open(zip_file_path).read
    zip_hash = Digest::MD5.hexdigest(zip)

    # execute 1
    object_keys = EdinetCode.put_edinet_code_list(zip)

    # postcondition 1
    assert_equal "edinet_code_list.zip", object_keys[:original]
    assert_match /^edinet_code_list\.zip\.bak_[0-9]{8}-[0-9]{6}$/, object_keys[:backup]
    assert @bucket.object(object_keys[:original]).exists?
    assert @bucket.object(object_keys[:backup]).exists?

    # execute 2
    zip_saved = EdinetCode.get_edinet_code_list
    zip_saved_hash = Digest::MD5.hexdigest(zip_saved)

    # postcondition 2
    assert_equal zip_hash, zip_saved_hash
  end

  test "import edinet code list" do
    # precondition
    zip_file_path = Rails.root.join("test", "fixtures", "files", "edinet_code", "Edinetcode_20180711_short.zip")
    zip = File.open(zip_file_path).read

    edinet_codes = EdinetCode.parse_edinet_code_list(zip)

    # execute
    edinet_code_ids = EdinetCode.import(edinet_codes)

    # postcondition
    assert_equal 10, edinet_codes.length
    assert_equal 10, EdinetCode.all.length
    assert_equal 10, edinet_code_ids.length

    edinet_code_ids.each do |edinet_code_id|
      assert EdinetCode.exists?(edinet_code_id)
    end

    edinet_codes.each do |edinet_code|
      assert edinet_code.same?(EdinetCode.find_by_edinet_code(edinet_code.edinet_code))
    end
  end

  test "import duplicate edinet code" do
    # precondition 
    zip_file_path = Rails.root.join("test", "fixtures", "files", "edinet_code", "Edinetcode_20180711_short.zip")
    zip = File.open(zip_file_path).read

    edinet_codes = EdinetCode.parse_edinet_code_list(zip)
    edinet_code_ids = EdinetCode.import(edinet_codes)

    edinet_codes_2 = [
      EdinetCode.new(edinet_code: "E00004", submitter_type: "aaa", submitter_name: "bbb")
    ]

    # execute 2
    edinet_code_ids_2 = EdinetCode.import(edinet_codes_2)

    # postcondition 2
    assert_equal 10, EdinetCode.all.length
    assert_equal 1, edinet_code_ids_2.length

    edinet_code_ids_2.each do |edinet_code_id|
      assert EdinetCode.exists?(edinet_code_id)
    end

    edinet_codes.each do |edinet_code|
      if edinet_code.edinet_code != "E00004"
        assert edinet_code.same?(EdinetCode.find_by_edinet_code(edinet_code.edinet_code))
      end
    end

    edinet_codes_2.each do |edinet_code|
      assert edinet_code.same?(EdinetCode.find_by_edinet_code(edinet_code.edinet_code))
    end
  end

  test "get stock via edinet_code" do
    # precondition
    stocks = [
      Stock.new(ticker_symbol: "1001", company_name: "foo", market: "hoge"),
      Stock.new(ticker_symbol: "1002", company_name: "bar", market: "hoge"),
      Stock.new(ticker_symbol: "1003", company_name: "boo", market: "hoge")
    ]
    Stock.import(stocks)

    edinet_code = EdinetCode.new(edinet_code: "E00001", submitter_type: "aaa", submitter_name: "AAA", ticker_symbol: "10010")

    # execute
    stock = edinet_code.get_stock

    # postcondition
    assert_equal "1001", stock.ticker_symbol
    assert_equal "foo", stock.company_name
    assert_equal "hoge", stock.market
  end

  test "get stock via edinet_code, case nil" do
    # precondition
    stocks = [
      Stock.new(ticker_symbol: "1001", company_name: "foo", market: "hoge"),
      Stock.new(ticker_symbol: "1002", company_name: "bar", market: "hoge"),
      Stock.new(ticker_symbol: "1003", company_name: "boo", market: "hoge")
    ]
    Stock.import(stocks)

    edinet_code = EdinetCode.new(edinet_code: "E00002", submitter_type: "bbb", submitter_name: "BBB")

    # execute
    stock = edinet_code.get_stock

    # postcondition
    assert_nil stock
  end

  test "get stock via edinet_code, case exception" do
    # precondition
    stocks = [
      Stock.new(ticker_symbol: "1001", company_name: "foo", market: "hoge"),
      Stock.new(ticker_symbol: "1002", company_name: "bar", market: "hoge"),
      Stock.new(ticker_symbol: "1003", company_name: "boo", market: "hoge")
    ]
    Stock.import(stocks)

    edinet_code = EdinetCode.new(edinet_code: "E00002", submitter_type: "bbb", submitter_name: "BBB", ticker_symbol: "20010")

    # execute
    assert_raise RuntimeError, "Stock not found. ticker_symbol=2001" do
      edinet_code.get_stock
    end
  end

  test "edinet code find by ticker_symbol" do
    # precondition
    edinet_codes = [
      EdinetCode.new(edinet_code: "E00001", submitter_type: "aaa", submitter_name: "AAA", ticker_symbol: "10010"),
      EdinetCode.new(edinet_code: "E00002", submitter_type: "bbb", submitter_name: "BBB", ticker_symbol: "10020"),
      EdinetCode.new(edinet_code: "E00003", submitter_type: "ccc", submitter_name: "CCC", ticker_symbol: "10030"),
    ]
    EdinetCode.import(edinet_codes)

    # execute
    edinet_code = EdinetCode.find_by_ticker_symbol("1002")

    # postcondition
    assert_equal "E00002", edinet_code.edinet_code
    assert_equal "bbb", edinet_code.submitter_type
    assert_equal "BBB", edinet_code.submitter_name
    assert_equal "10020", edinet_code.ticker_symbol
  end

  test "edinet code find by ticker_symbol, case not found" do
    # precondition
    edinet_codes = [
      EdinetCode.new(edinet_code: "E00001", submitter_type: "aaa", submitter_name: "AAA", ticker_symbol: "10010"),
      EdinetCode.new(edinet_code: "E00002", submitter_type: "bbb", submitter_name: "BBB", ticker_symbol: "10020"),
      EdinetCode.new(edinet_code: "E00003", submitter_type: "ccc", submitter_name: "CCC", ticker_symbol: "10030"),
    ]
    EdinetCode.import(edinet_codes)

    # execute
    edinet_code = EdinetCode.find_by_ticker_symbol("9999")

    # postcondition
    assert_nil edinet_code
  end

end
