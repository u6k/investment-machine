RSpec.describe InvestmentMachine::Parser::XbrlZipParser do
  before do
    url = "https://resource.ufocatch.com/data/edinet/ED2019032500001"
    data = {
      "url" => "https://resource.ufocatch.com/data/edinet/ED2019032500001",
      "request_method" => "GET",
      "request_headers" => {},
      "response_headers" => {},
      "response_body" => File.open("spec/data/ED2019032500001.zip").read,
      "downloaded_timestamp" => Time.now.utc}

    @parser = InvestmentMachine::Parser::XbrlZipParser.new(url, data)
  end

  describe "#redownload?" do
    it "do not redownload always" do
      expect(@parser).not_to be_redownload
    end
  end

  describe "#valid?" do
    context "valid xbrl zip" do
      it "is valid" do
        expect(@parser).to be_valid
      end
    end
  end

  describe "#related_links" do
    it "is empty" do
      expect(@parser.related_links).to be_empty
    end
  end

  describe "#parse" do
    it "is zip entry" do # TODO parse xbrl eventually
      context = {}

      @parser.parse(context)

      expect(context).to match(
        "zip_entries" => [
          "S100FFJU/XBRL/AuditDoc/jpaud-aai-cc-001_E01728-000_2018-12-31_01_2019-03-25.xbrl",
          "S100FFJU/XBRL/AuditDoc/jpaud-aai-cc-001_E01728-000_2018-12-31_01_2019-03-25.xsd",
          "S100FFJU/XBRL/AuditDoc/jpaud-aai-cc-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/AuditDoc/jpaud-aai-cc-001_E01728-000_2018-12-31_01_2019-03-25_pre.xml",
          "S100FFJU/XBRL/AuditDoc/jpaud-aar-cn-001_E01728-000_2018-12-31_01_2019-03-25.xbrl",
          "S100FFJU/XBRL/AuditDoc/jpaud-aar-cn-001_E01728-000_2018-12-31_01_2019-03-25.xsd",
          "S100FFJU/XBRL/AuditDoc/jpaud-aar-cn-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/AuditDoc/jpaud-aar-cn-001_E01728-000_2018-12-31_01_2019-03-25_pre.xml",
          "S100FFJU/XBRL/AuditDoc/manifest_AuditDoc.xml",
          "S100FFJU/XBRL/PublicDoc/0000000_header_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0101010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0102010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0103010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0104010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105000_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105020_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105025_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105040_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105050_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105100_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105120_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105310_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105320_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105330_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105400_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0105410_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0106010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0107010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/0201010_honbun_jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_ixbrl.htm",
          "S100FFJU/XBRL/PublicDoc/jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25.xbrl",
          "S100FFJU/XBRL/PublicDoc/jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25.xsd",
          "S100FFJU/XBRL/PublicDoc/jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_cal.xml",
          "S100FFJU/XBRL/PublicDoc/jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_def.xml",
          "S100FFJU/XBRL/PublicDoc/jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_lab.xml",
          "S100FFJU/XBRL/PublicDoc/jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_lab-en.xml",
          "S100FFJU/XBRL/PublicDoc/jpcrp030000-asr-001_E01728-000_2018-12-31_01_2019-03-25_pre.xml",
          "S100FFJU/XBRL/PublicDoc/manifest_PublicDoc.xml",
          "S100FFJU/XBRL/PublicDoc/fuzoku/50_0822500103103.gif",
          "S100FFJU/XBRL/PublicDoc/fuzoku/51_0822500103103.gif"
        ]
      )
    end
  end
end

