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
    { data: data }
  end

end
