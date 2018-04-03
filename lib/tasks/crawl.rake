require "open-uri"
require "nokogiri"

namespace :crawl do
  desc "TODO"

  task hello: :environment do
    url = "http://blog.u6k.me"

    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)

    p doc.title
  end

end
