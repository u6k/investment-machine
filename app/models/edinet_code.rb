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
        raise "column value not 'ダウンロード実行日'" if line[0] != "ダウンロード実行日"
        raise "column value not '件数'" if line[2] != "件数"
      elsif index == 1
        raise "column value not 'ＥＤＩＮＥＴコード'" if line[0] != "ＥＤＩＮＥＴコード"
        raise "column value not '提出者種別'" if line[1] != "提出者種別"
        raise "column value not '上場区分'" if line[2] != "上場区分"
        raise "column value not '連結の有無'" if line[3] != "連結の有無"
        raise "column value not '資本金'" if line[4] != "資本金"
        raise "column value not '決算日'" if line[5] != "決算日"
        raise "column value not '提出者名'" if line[6] != "提出者名"
        raise "column value not '提出者名（英字）'" if line[7] != "提出者名（英字）"
        raise "column value not '提出者名（ヨミ）'" if line[8] != "提出者名（ヨミ）"
        raise "column value not '所在地'" if line[9] != "所在地"
        raise "column value not '提出者業種'" if line[10] != "提出者業種"
        raise "column value not '証券コード'" if line[11] != "証券コード"
        raise "column value not '提出者法人番号'" if line[12] != "提出者法人番号"
      else
        edinet_code = EdinetCode.new(
          edinet_code: line[0].presence,
          submitter_type: line[1].presence,
          listed: line[2].presence,
          consolidated: line[3].presence,
          capital: line[4].empty? ? nil : line[4].to_i,
          settlement_date: line[5].presence,
          submitter_name: line[6].presence,
          submitter_name_en: line[7].presence,
          submitter_name_yomi: line[8].presence,
          address: line[9].presence,
          industry: line[10].presence,
          ticker_symbol: line[11].presence,
          corporate_number: line[12].presence
        )
        raise edinet_code.errors.messages.to_s if edinet_code.invalid?

        edinet_codes << edinet_code
      end
    end

    edinet_codes
  end

end
