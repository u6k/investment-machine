require "bundler/setup"
require "investment_machine"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  # Database config
  db_config = {
    adapter: "postgresql",
    database: ENV["DB_DATABASE"],
    host: ENV["DB_HOST"],
    port: ENV["DB_PORT"],
    username: ENV["DB_USERNAME"],
    password: ENV["DB_PASSWORD"],
    sslmode: ENV["DB_SSLMODE"]
  }

  ActiveRecord::Base.establish_connection db_config
end

