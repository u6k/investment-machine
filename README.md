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

その他の情報は、 [Wiki - investment-machine - u6k.Redmine](https://redmine.u6k.me/projects/investment-machine/wiki) を参照してください。

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

