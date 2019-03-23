# 投資マシン _(investment-machine)_

[![Travis](https://img.shields.io/travis/u6k/investment-machine.svg)](https://travis-ci.org/u6k/investment-machine) [![license](https://img.shields.io/github/license/u6k/investment-machine.svg)](https://github.com/u6k/investment-machine/blob/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/u6k/investment-machine.svg)](https://github.com/u6k/investment-machine/releases) [![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme) [![WebSite](https://img.shields.io/website-up-down-green-red/https/shields.io.svg?label=u6k.Redmine)](https://redmine.u6k.me/projects/investment-machine)

> 投資をサポートする

__Table of Contents__

- [Install](#Install)
- [Usage](#Usage)
- [Other](#Other)
- [API](#API)
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
gem 'investment_machine', :git => 'https://github.com/u6k/investment-machine.git'
```

## Usage

```
$ investment-machine help
Commands:
  investment-machine crawl           # Crawl stocks
  investment-machine help [COMMAND]  # Describe available commands or one specific command
  investment-machine version         # Display version
```

## Other

最新の情報は、 [Wiki - investment-machine - u6k.Redmine](https://redmine.u6k.me/projects/investment-machine/wiki) を参照してください。

- [基本情報](https://redmine.u6k.me/projects/investment-machine/wiki/%E5%9F%BA%E6%9C%AC%E6%83%85%E5%A0%B1)
- [関連サイト](https://redmine.u6k.me/projects/investment-machine/wiki/%E9%96%A2%E9%80%A3%E3%82%B5%E3%82%A4%E3%83%88)
- [外部データソース構造](https://redmine.u6k.me/projects/investment-machine/wiki/%E5%A4%96%E9%83%A8%E3%83%87%E3%83%BC%E3%82%BF%E3%82%BD%E3%83%BC%E3%82%B9%E6%A7%8B%E9%80%A0)
- [データ構造](https://redmine.u6k.me/projects/investment-machine/wiki/%E3%83%87%E3%83%BC%E3%82%BF%E6%A7%8B%E9%80%A0)
- [リリース手順](https://redmine.u6k.me/projects/investment-machine/wiki/%E3%83%AA%E3%83%AA%E3%83%BC%E3%82%B9%E6%89%8B%E9%A0%86)

## API

[APIリファレンス](https://u6k.github.io/investment-machine/) を参照してください。

## Maintainer

- u6k
    - [Twitter](https://twitter.com/u6k_yu1)
    - [GitHub](https://github.com/u6k)
    - [Blog](https://blog.u6k.me/)

## Contributing

当プロジェクトに興味を持っていただき、ありがとうございます。[新しいチケットを起票](https://redmine.u6k.me/projects/investment-machine/issues/new)していただくか、プルリクエストをサブミットしていただけると幸いです。

当プロジェクトは、[Contributor Covenant](https://www.contributor-covenant.org/version/1/4/code-of-conduct)に準拠します。

## License

[MIT License](https://github.com/u6k/investment-machine/blob/master/LICENSE)
