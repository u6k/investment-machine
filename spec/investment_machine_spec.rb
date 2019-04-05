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

    WebMock.stub_request(:get, /https:\/\/quotes\.wsj\.com\/.*$/).to_return(
      status: [404, "Not Found"])

    WebMock.stub_request(:get, "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/").to_return(
      status: [200, "OK"],
      body: "test")

    WebMock.stub_request(:get, "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2019&endDate=12/31/2019").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/topix.2019.csv").read)

    WebMock.stub_request(:get, "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1990&endDate=12/31/1990").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/topix.1990.csv").read)

    WebMock.stub_request(:get, "https://quotes.wsj.com/index/DJIA/historical-prices/").to_return(
      status: [200, "OK"],
      body: "test")

    WebMock.stub_request(:get, "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/1990&endDate=12/31/1990").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/djia.1990.csv").read)

    WebMock.stub_request(:get, "https://quotes.wsj.com/index/DJIA/historical-prices/download?MOD_VIEW=page&num_rows=366&range_days=366&startDate=01/01/2019&endDate=12/31/2019").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/djia.2019.csv").read)

    WebMock.disable_net_connect!(allow: "s3")

    # Setup database
    InvestmentMachine::Model::Company.delete_all
    InvestmentMachine::Model::StockPrice.delete_all
    InvestmentMachine::Model::NikkeiAverage.delete_all
    InvestmentMachine::Model::Topix.delete_all
    InvestmentMachine::Model::Djia.delete_all

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
                                      interval: 0.001,
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

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
                                      interval: 0.001,
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])
    InvestmentMachine::CLI.new.invoke("parse", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

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
                                      entrypoint_url: "https://resource.ufocatch.com/atom/edinetx",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

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
                                      entrypoint_url: "https://resource.ufocatch.com/atom/tdnetx",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

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
                                      entrypoint_url: "https://indexes.nikkei.co.jp/nkave/archives/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::NikkeiAverage.count).to eq 0
  end

  it "parse nikkei average is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://indexes.nikkei.co.jp/nkave/archives/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])
    InvestmentMachine::CLI.new.invoke("parse", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"],
                                      entrypoint_url: "https://indexes.nikkei.co.jp/nkave/archives/")

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::NikkeiAverage.count).to be > 0
  end

  it "crawl topix is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Topix.count).to eq 0
  end

  it "parse topix is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])
    InvestmentMachine::CLI.new.invoke("parse", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      entrypoint_url: "https://quotes.wsj.com/index/JP/XTKS/I0000/historical-prices/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Topix.count).to be > 0
  end

  it "crawl djia is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://quotes.wsj.com/index/DJIA/historical-prices/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Djia.count).to eq 0
  end

  it "parse djia is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      interval: 0.001,
                                      entrypoint_url: "https://quotes.wsj.com/index/DJIA/historical-prices/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])
    InvestmentMachine::CLI.new.invoke("parse", [],
                                      s3_access_key: ENV["AWS_S3_ACCESS_KEY"],
                                      s3_secret_key: ENV["AWS_S3_SECRET_KEY"],
                                      s3_region: ENV["AWS_S3_REGION"],
                                      s3_bucket: ENV["AWS_S3_BUCKET"],
                                      s3_endpoint: ENV["AWS_S3_ENDPOINT"],
                                      s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"],
                                      entrypoint_url: "https://quotes.wsj.com/index/DJIA/historical-prices/",
                                      db_database: ENV["DB_DATABASE"],
                                      db_host: ENV["DB_HOST"],
                                      db_port: ENV["DB_PORT"],
                                      db_username: ENV["DB_USERNAME"],
                                      db_password: ENV["DB_PASSWORD"],
                                      db_sslmode: ENV["DB_SSLMODE"])

    expect(count_s3_objects).to be > 0
    expect(InvestmentMachine::Model::Djia.count).to be > 0
  end

  def count_s3_objects
    count = 0

    @repo.list_s3_objects { count += 1 }

    count
  end
end

