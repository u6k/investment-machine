require "webmock/rspec"

RSpec.describe InvestmentMachine do
  it "has a version number" do
    expect(InvestmentMachine::VERSION).not_to be nil
  end
end

RSpec.describe InvestmentMachine::CLI do
  before do
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

    WebMock.disable_net_connect!(allow: "s3")
  end

  after do
    WebMock.disable!
  end

  it "is version" do
    stdout = capture(:stdout) { InvestmentMachine::CLI.new.invoke("version") }

    expect(stdout).to eq "#{InvestmentMachine::VERSION}\n"
  end

  it "crawl stocks is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [], s3_access_key: ENV["AWS_S3_ACCESS_KEY"], s3_secret_key: ENV["AWS_S3_SECRET_KEY"], s3_region: ENV["AWS_S3_REGION"], s3_bucket: ENV["AWS_S3_BUCKET"], s3_endpoint: ENV["AWS_S3_ENDPOINT"], s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"], interval: 0.001)
  end

  it "crawl edinet atom is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [], s3_access_key: ENV["AWS_S3_ACCESS_KEY"], s3_secret_key: ENV["AWS_S3_SECRET_KEY"], s3_region: ENV["AWS_S3_REGION"], s3_bucket: ENV["AWS_S3_BUCKET"], s3_endpoint: ENV["AWS_S3_ENDPOINT"], s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"], interval: 0.001, entrypoint_url: "https://resource.ufocatch.com/atom/edinetx")
  end

  it "crawl tdnet atom is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [], s3_access_key: ENV["AWS_S3_ACCESS_KEY"], s3_secret_key: ENV["AWS_S3_SECRET_KEY"], s3_region: ENV["AWS_S3_REGION"], s3_bucket: ENV["AWS_S3_BUCKET"], s3_endpoint: ENV["AWS_S3_ENDPOINT"], s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"], interval: 0.001, entrypoint_url: "https://resource.ufocatch.com/atom/tdnetx")
  end

end

