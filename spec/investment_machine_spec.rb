require "webmock/rspec"

RSpec.describe InvestmentMachine do
  it "has a version number" do
    expect(InvestmentMachine::VERSION).not_to be nil
  end
end

RSpec.describe InvestmentMachine::CLI do
  before do
    WebMock.enable!

    WebMock.stub_request(:get, /https:\/\/kabuoji3\.com\/.*/).to_return(
      status: [404, "Not Found"])

    WebMock.stub_request(:get, "https://kabuoji3.com/stock/").to_return(
      status: [200, "OK"],
      body: File.open("spec/data/stock_list_page.html").read)

    WebMock.disable_net_connect!(allow: "s3")
  end

  after do
    WebMock.disable!
  end

  it "is version" do
    stdout = capture(:stdout) { InvestmentMachine::CLI.new.invoke("version") }

    expect(stdout).to eq "#{InvestmentMachine::VERSION}\n"
  end

  it "crawl is success" do
    InvestmentMachine::CLI.new.invoke("crawl", [], s3_access_key: ENV["AWS_S3_ACCESS_KEY"], s3_secret_key: ENV["AWS_S3_SECRET_KEY"], s3_region: ENV["AWS_S3_REGION"], s3_bucket: ENV["AWS_S3_BUCKET"], s3_endpoint: ENV["AWS_S3_ENDPOINT"], s3_force_path_style: ENV["AWS_S3_FORCE_PATH_STYLE"], interval: 0.001)
  end
end

