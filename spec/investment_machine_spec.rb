require "webmock/rspec"

RSpec.describe InvestmentMachine do
  it "has a version number" do
    expect(InvestmentMachine::VERSION).not_to be nil
  end
end

RSpec.describe InvestmentMachine::CLI do
  before do
    # Setup WebMock
    WebMock.enable!

    WebMock.stub_request(:get, /^https:\/\/kabuoji3\.com\/.*$/).to_return(
      status: [404, "Not Found"])

    WebMock.stub_request(:get, "https://kabuoji3.com/stock/").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_list_page.html").read)

    WebMock.stub_request(:get, "https://kabuoji3.com/stock/1301/").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_prices_page.1301.html").read)

    WebMock.stub_request(:get, "https://kabuoji3.com/stock/1301/2019/").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_prices_page.1301.html").read)

    WebMock.stub_request(:get, /^https:\/\/resource\.ufocatch\.com\/.*$/).to_return(
      status: [404, "Not Found"])

    WebMock.stub_request(:get, "https://resource.ufocatch.com/atom/edinetx").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/ufocatch_edinet.1.atom").read)

    WebMock.stub_request(:get, "https://resource.ufocatch.com/atom/tdnetx").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/ufocatch_tdnet.1.atom").read)

    WebMock.stub_request(:get, "https://resource.ufocatch.com/data/edinet/ED2019032500001").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/ED2019032500001.zip").read)

    WebMock.stub_request(:get, /^https:\/\/indexes\.nikkei\.co\.jp\/nkave\/.*$/).to_return(
      status: [404, "Not Found"])

    WebMock.stub_request(:get, "https://indexes.nikkei.co.jp/nkave/archives/").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/nikkei_average.index.html").read)

    WebMock.stub_request(:get, "https://indexes.nikkei.co.jp/nkave/statistics/dataload?list=daily&year=2019&month=2").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/nikkei_average.201902.html").read)

    WebMock.disable_net_connect!(allow: "s3")

    # Setup database
    InvestmentMachine::Model::Company.delete_all
    InvestmentMachine::Model::StockPrice.delete_all

    # Setup resource repository
    @repo = Crawline::ResourceRepository.new(ENV["AWS_S3_ACCESS_KEY"], ENV["AWS_S3_SECRET_KEY"], ENV["AWS_S3_REGION"], ENV["AWS_S3_BUCKET"], ENV["AWS_S3_ENDPOINT"], ENV["AWS_S3_FORCE_PATH_STYLE"], nil)
    @repo.remove_s3_objects
  end

  after do
    WebMock.disable!
  end

  it "is version" do
    stdout = capture(:stdout) { InvestmentMachine::CLI.new.invoke("version") }

    expect(stdout).to eq "#{InvestmentMachine::VERSION}\n"
  end

  it "crawl stocks is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001)

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Company.count).to eq 0
    expect(InvestmentMachine::Model::StockPrice.count).to eq 0
  end

  it "parse stocks is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001)
    InvestmentMachine::CLI.new.invoke("parse", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"])

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Company.count).to be > 0
    expect(InvestmentMachine::Model::StockPrice.count).to be > 0
  end

  it "crawl edinet atom is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://resource.ufocatch.com/atom/edinetx")

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Company.count).to eq 0
    expect(InvestmentMachine::Model::StockPrice.count).to eq 0
  end

  it "crawl tdnet atom is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://resource.ufocatch.com/atom/tdnetx")

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Company.count).to eq 0
    expect(InvestmentMachine::Model::StockPrice.count).to eq 0
  end

  it "crawl nikkei average is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://indexes.nikkei.co.jp/nkave/archives/")

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Company.count).to eq 0
    expect(InvestmentMachine::Model::StockPrice.count).to eq 0
  end

  def count_s3_objects
    count = 0

    @repo.list_s3_objects { count += 1 }

    count
  end
end

