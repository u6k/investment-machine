RSpec.describe InvestmentMachine do
  it "has a version number" do
    expect(InvestmentMachine::VERSION).not_to be nil
  end
end

RSpec.describe InvestmentMachine::CLI do
  it "is version" do
    stdout = capture(:stdout) { InvestmentMachine::CLI.new.invoke("version") }

    expect(stdout).to eq "#{InvestmentMachine::VERSION}\n"
  end
end

