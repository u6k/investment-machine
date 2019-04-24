# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2019-04-24

### Changed

- [#6901: クローラー機能、判断機能のリポジトリを分ける](https://redmine.u6k.me/issues/6901)
    - `investment-machine`から`investment-stocks-crawler`にリネームしました
    - 既にある程度運用しているので、これを機にメジャー・バージョンを1にします

## [0.11.1] - 2019-04-10

### Added

- [#6895: 実際のデータソースにアクセスして、少なくともvalidであることをテストする](https://redmine.u6k.me/issues/6895)

## [0.11.0] - 2019-04-10

### Added

- [#6910: データのキャッシュ状況を確認するコマンドを実装する](https://redmine.u6k.me/issues/6910)

## [0.10.0] - 2019-04-06

### Added

- [#6899: DB接続で、ポート番号とSSLを設定できるようにする](https://redmine.u6k.me/issues/6899)

## [0.9.0] - 2019-04-05

### Added

- [#6857: ダウ平均パーサーを実装する](https://redmine.u6k.me/issues/6857)

## [0.8.0] - 2019-04-03

### Added

- [#6860: TOPIXパーサーを実装する](https://redmine.u6k.me/issues/6860)

## [0.7.1] - 2019-03-31

### Fixed

- [#6876: crawlしたらActiveRecord::ConnectionNotEstablishedが発生した](https://redmine.u6k.me/issues/6876)

## [0.7.0] - 2019-03-31

### Added

- [#6873: 日経平均株価をDBに格納する](https://redmine.u6k.me/issues/6873)

## [0.6.0] - 2019-03-29

### Added

- [#6866: 企業・株価データをDBに格納する](https://redmine.u6k.me/issues/6866)

## [0.5.0] - 2019-03-28

### Added

- [#6859: 日経平均株価パーサーを実装する](https://redmine.u6k.me/issues/6859)

## [0.4.0] - 2019-03-25

### Fixed

- [#6861: 有価証券報告書パーサーを実装する](https://redmine.u6k.me/issues/6861)
    - CLIにパーサーを追加しました

## [0.3.0] - 2019-03-25

### Added

- [#6861: 有価証券報告書パーサーを実装する](https://redmine.u6k.me/issues/6861)

## [0.2.0] - 2019-03-24

### Added

- [#6856: 株価ページ・パーサーを実装する](https://redmine.u6k.me/issues/6856)

## [0.1.0] - 2019-03-24

### Changed

- [#6741: CLIアプリに変更する](https://redmine.u6k.me/issues/6741)
