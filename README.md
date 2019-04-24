# 株式投資クローラー _(investment-stocks-crawler)_

[![Travis](https://img.shields.io/travis/u6k/investment-stocks-crawler.svg)](https://travis-ci.org/u6k/investment-stocks-crawler) [![license](https://img.shields.io/github/license/u6k/investment-stocks-crawler.svg)](https://github.com/u6k/investment-stocks-crawler/blob/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/u6k/investment-stocks-crawler.svg)](https://github.com/u6k/investment-stocks-crawler/releases) [![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme) [![WebSite](https://img.shields.io/website-up-down-green-red/https/shields.io.svg?label=u6k.Redmine)](https://redmine.u6k.me/projects/investment-stocks)

> 株式投資に使用するデータを収集する

__Table of Contents__

- [Install](#Install)
- [Usage](#Usage)
- [Other](#Other)
- [Disclaimer](#Disclaimer)
- [Maintainer](#Maintainer)
- [Contributing](#Contributing)
- [License](#License)

## Install

Rubyを使用します。

```
$ ruby --version
ruby 2.6.0p0 (2018-12-25 revision 66547) [x86_64-linux]
```

`Gemfile`に次を追加して、`bundle install`でインストールします。

```
gem 'crawline', :git => 'https://github.com/u6k/crawline.git'
gem 'investment_stocks-crawler', :git => 'https://github.com/u6k/investment-stocks-crawler.git'
```

## Usage

```
$ investment-stocks-crawler help
Commands:
  investment-stocks-crawler crawl             # Crawl stocks
  investment-stocks-crawler help [COMMAND]    # Describe available commands or one specific command
  investment-stocks-crawler list_cache_state  # Listing cache state
  investment-stocks-crawler parse             # Parse stocks
  investment-stocks-crawler version           # Display version
```

## Other

その他の情報は、[investment-stocks-crawler \| u6k.Redmine](https://redmine.u6k.me/projects/investment-stocks-crawler/wiki/Wiki)を参照してください。


## Disclaimer

- 本プロジェクトの内容は、作者個人が趣味の範囲で自発的に行ったものです。作者が所属する会社または団体は本プロジェクトについて、一切関知しておらず、何ら責任や関連はありません。
- 本プロジェクトの内容は、作者個人が運用する目的としたものであり、投資の勧誘を目的としたものではありません。
- 本プロジェクトの内容またはそれを元にして作成したアプリケーションあるいはそれによる予測(以下、その成果物が生成する情報と呼称する)を参考にして、投資の判断を行わないでください。また、本プロジェクトの内容またはその成果物が生成する情報が正確であることを、作者は一切保証しません。未来の出来事に対する予想も、あくまで予想であり、その時々の状況によって変わりうることにご注意ください。
- 投資を行う際には、投資を行う本人のみの判断と責任において行ってください。
- 仮に投資に失敗し、投資を行ったものの資産が減ったり債務を負ったりしても、作者は何ら責任を負いません。
- その他、本プロジェクトを参考にしたかどうかに関わらず、投資の失敗や機会の損失などを含むいかなる不利益が何人に生じたとしても、作者は何ら責任を負いません。

__TODO:__ 利用規約書籍を元に免責事項を見直す

## Maintainer

- u6k
    - [Twitter](https://twitter.com/u6k_yu1)
    - [GitHub](https://github.com/u6k)
    - [Blog](https://blog.u6k.me/)

## Contributing

当プロジェクトに興味を持っていただき、ありがとうございます。[新しいチケットを起票](https://redmine.u6k.me/projects/investment-stocks-crawler/issues)していただけると幸いです。

当プロジェクトは、[Contributor Covenant](https://www.contributor-covenant.org/version/1/4/code-of-conduct)に準拠します。

## License

[MIT License](https://github.com/u6k/investment-stocks-crawler/blob/master/LICENSE)

