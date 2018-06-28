# 投資マシン _(investment-machine)_

[![Travis](https://img.shields.io/travis/u6k/investment-machine.svg)](https://travis-ci.org/u6k/investment-machine)
[![license](https://img.shields.io/github/license/u6k/investment-machine.svg)](https://github.com/u6k/investment-machine/blob/master/LICENSE)
[![GitHub tag](https://img.shields.io/github/tag/u6k/investment-machine.svg)](https://github.com/u6k/investment-machine/releases)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> 投資マシン。

## Install

Dockerを使用します。

```
$ docker version
Client:
 Version:       18.03.0-ce
 API version:   1.37
 Go version:    go1.9.4
 Git commit:    0520e24
 Built: Wed Mar 21 23:06:22 2018
 OS/Arch:       darwin/amd64
 Experimental:  false
 Orchestrator:  swarm

Server:
 Engine:
  Version:      18.03.0-ce
  API version:  1.37 (minimum version 1.12)
  Go version:   go1.9.4
  Git commit:   0520e24
  Built:        Wed Mar 21 23:14:32 2018
  OS/Arch:      linux/amd64
  Experimental: true
yu1-no-MacBook-Pro:investment-machine yu1$

$ docker-compose version
docker-compose version 1.20.1, build 5d8c71b
docker-py version: 3.1.4
CPython version: 3.6.4
OpenSSL version: OpenSSL 1.0.2n  7 Dec 2017
```

ビルド手順は、`.travis.yml`を参照すること。起動は`docker-compose.production.yml`を参照すること。

## Development

開発用Dockerイメージをビルドします。

```
$ docker-compose build
```

環境変数を設定するため、 `.env` を作成します。

```
$ mv .env.example .env
```

開発用Dockerコンテナを起動します。

```
$ docker-compose up -d
```

DBをマイグレートします。

```
$ docker-compose exec app rails db:migrate
```

Minioのバケットを作成します。

```
$ docker-compose exec s3 mkdir /export/investment
```

テストを実行します。

```
$ docker-compose exec app rails test
```

簡単に動作確認をします。

```
$ curl http://localhost:3000
```

## API

|API|URL|
|---|---|
|ヘルスチェック|/okcomputer/all.json|

## Maintainer

- [u6k - GitHub](https://github.com/u6k/)
- [u6k.Blog()](https://blog.u6k.me/)
- [u6k_yu1 | Twitter](https://twitter.com/u6k_yu1)

## Contribute

ライセンスの範囲内で、ご自由にご使用ください。

## License

[MIT License](https://github.com/u6k/investment-machine/blob/master/LICENSE)
