require 'test_helper'

class CrawlTest < ActionDispatch::IntegrationTest

  def setup
    Myapp::Application.load_tasks
  end

  test "test" do
    # TODO
    Rake::Task["crawl:hello"].invoke(ticker_symbol: "1002", year: 2018)
  end

end
