require "csv"
require "zip"

class EdinetCode < ApplicationRecord

  validates :edinet_code, presence: true
  validates :submitter_type, presence: true
  validates :submitter_name, presence: true

  def self.build_edinet_code_list_file_name
    "edinet_code_list.zip"
  end

  def self.download_edinet_code_list
    url = "https://disclosure.edinet-fsa.go.jp//E01EW/download?1531279350133&uji.verb=W1E62071EdinetCodeDownload&uji.bean=ee.bean.W1E62071.EEW1E62071Bean&TID=W1E62071&PID=W1E62071&lgKbn=2&dflg=0&iflg=0&dispKbn=1"
    file_name = build_edinet_code_list_file_name

    data = Stock._download_with_get(url)
    edinet_codes = parse_edinet_code_list(data)
    { data: data, edinet_codes: edinet_codes }
  end

  def self.parse_edinet_code_list(zip_data)
    edinet_code_list_csv = nil
    Zip::File.open_buffer(zip_data) do |zip|
      edinet_code_list_csv = zip.find_entry("EdinetcodeDlInfo.csv").get_input_stream.read
    end

    edinet_code_list_csv = edinet_code_list_csv.encode("UTF-8", "Shift_JIS", :invalid => :replace, :undef => :replace)

    edinet_codes = []
    CSV.parse(edinet_code_list_csv).map.with_index(0) do |line, index|
      if index == 0
        raise "column value not '$B%@%&%s%m!<%I<B9TF|(B'" if line[0] != "$B%@%&%s%m!<%I<B9TF|(B"
        raise "column value not '$B7o?t(B'" if line[2] != "$B7o?t(B"
      elsif index == 1
        raise "column value not '$B#E#D#I#N#E#T%3!<%I(B'" if line[0] != "$B#E#D#I#N#E#T%3!<%I(B"
        raise "column value not '$BDs=P<T<oJL(B'" if line[1] != "$BDs=P<T<oJL(B"
        raise "column value not '$B>e>l6hJ,(B'" if line[2] != "$B>e>l6hJ,(B"
        raise "column value not '$BO"7k$NM-L5(B'" if line[3] != "$BO"7k$NM-L5(B"
        raise "column value not '$B;qK\6b(B'" if line[4] != "$B;qK\6b(B"
        raise "column value not '$B7h;;F|(B'" if line[5] != "$B7h;;F|(B"
        raise "column value not '$BDs=P<TL>(B'" if line[6] != "$BDs=P<TL>(B"
        raise "column value not '$BDs=P<TL>!J1Q;z!K(B'" if line[7] != "$BDs=P<TL>!J1Q;z!K(B"
        raise "column value not '$BDs=P<TL>!J%h%_!K(B'" if line[8] != "$BDs=P<TL>!J%h%_!K(B"
        raise "column value not '$B=j:_CO(B'" if line[9] != "$B=j:_CO(B"
        raise "column value not '$BDs=P<T6H<o(B'" if line[10] != "$BDs=P<T6H<o(B"
        raise "column value not '$B>Z7t%3!<%I(B'" if line[11] != "$B>Z7t%3!<%I(B"
        raise "column value not '$BDs=P<TK!?MHV9f(B'" if line[12] != "$BDs=P<TK!?MHV9f(B"
      else
        edinet_code = EdinetCode.new(
          edinet_code: line[0],
          submitter_type: line[1],
          listed: line[2],
          consolidated: line[3],
          capital: line[4].to_i,
          settlement_date: line[5],
          submitter_name: line[6],
          submitter_name_en: line[7],
          submitter_name_yomi: line[8],
          address: line[9],
          industry: line[10],
          ticker_symbol: line[11],
          corporate_number: line[12]
        )
        raise edinet_code.errors.messages.to_s if edinet_code.invalid?

        edinet_codes << edinet_code
      end
    end

    edinet_codes
  end

end
