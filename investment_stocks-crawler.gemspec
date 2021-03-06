
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "investment_stocks/crawler/version"

Gem::Specification.new do |spec|
  spec.name          = "investment_stocks-crawler"
  spec.version       = InvestmentStocks::Crawler::VERSION
  spec.authors       = ["u6k"]
  spec.email         = ["u6k.apps@gmail.com"]

  spec.summary       = %q{Crawl stocks.}
  spec.homepage      = "https://github.com/u6k/investment-stocks-crawler"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'timecop', '~> 0.9.1'
  spec.add_development_dependency 'webmock', '~> 3.5', '>= 3.5.1'
  spec.add_development_dependency 'yard', '~> 0.9.18'

  spec.add_dependency "crawline"
  spec.add_dependency 'thor', '~> 0.20.3'
  spec.add_dependency 'nokogiri', '~> 1.10', '>= 1.10.1'
  spec.add_dependency 'rubyzip', '~> 1.2', '>= 1.2.2'
  spec.add_dependency 'pg'
  spec.add_dependency 'activerecord'
  spec.add_dependency 'standalone_migrations'
  spec.add_dependency 'activerecord-import', '~> 1.0', '>= 1.0.1'
end
