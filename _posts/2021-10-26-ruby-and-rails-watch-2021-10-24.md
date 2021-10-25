---
layout: single
title:  "【不定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-10-24)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-10-26T00:00:47:19+0900
---
Ruby と Rails を安定して使い続けるために **最新の Ruby と Rails に対して行われた変更がバージョンアップするときに問題になるかどうか** という観点で情報をまとめています。

情報が多いので時間がない人は [Rubyの仕様変更の一覧](#rubyの仕様変更の一覧) と [Railsの仕様変更の一覧](#railsの仕様変更の一覧) を見てください。

Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) で公開してくださっています。

Rails の最新情報は [Pull requests · rails/rails](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed) でマージされた PR を確認できるのと、[y-yagiさん (@y_yagi) / Twitter](https://twitter.com/y_yagi) が [なるようになるブログ](https://y-yagi.hatenablog.com/) と [TechRacho｜BPS株式会社のRuby on Rails開発情報サイト](https://techracho.bpsinc.jp/) が [週刊Railsウォッチの記事一覧｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/tag/%e9%80%b1%e5%88%8arails%e3%82%a6%e3%82%a9%e3%83%83%e3%83%81) で公開してくださっています。

これらは大変有益な情報です。本当にありがたいことです。

{% include advertisements.html %}

## Ruby

### Rubyの仕様変更の一覧

#### ruby trunk

- `require 'did_you_mean/formatters/plain_formatter'`
- `require 'did_you_mean/formatters/verbose_formatter'`
- CSV::Parserの問題のある行を解析する処理
- CSV::Parser のクラス変数 `@@string_scanner_scan_accept_string`

以下、変更点の詳細です。

### ruby trunk

- `ruby --enable=all` のときに YJIT が有効になります。ただし、 ruby 自身のビルドオプションによっては MJIT に戻すこともできます。

#### [ruby-trunk-changes 2021-10-22 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211022)

> [Fix TestRubyOptions#test_enable for -DMJIT_FORCE_ENABLE · ruby/ruby@6469038](https://github.com/ruby/ruby/commit/6469038ae2ca8a5f0ea8c1274030996240e7df70)

【仕様変更】
なるほど、昨日の YJIT 導入後は ruby --enable=all のときに YJIT が有効になり MJIT が無効になります。MJIT を期待していた人にとっては仕様変更があったんですね。

> [[ruby/uri] URI#HTTP#origin and URI#HTTP#authority (https://github.com… · ruby/ruby@553f234](https://github.com/ruby/ruby/commit/553f234a07fe000cf5416793c1f9c0273518d906)

OK
仕様変更ではありません。URI に便利なメソッドが追加されています。 authority と origin です。どちらも素敵！

> [[ruby/mutex_m] Make VERSION shareable · ruby/ruby@d09cb64](https://github.com/ruby/ruby/commit/d09cb64ae5c618f1cb2d90c544b7e0bc55ebb003)

[nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) もコメントされていましたが、たしかにこの修正の意図がわかりませんね...。 [PR](https://github.com/ruby/mutex_m/pull/7) には Ractor で共有するために修正したとあります。なぜ VERSION を共有しないといけないのかを知りたいんですよね。必要ならユーザーが共有すればよく、わざわざライブラリ側でする理由がわからない、ということです。

#### [ruby-trunk-changes 2021-10-23 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211023)

> [allow to access ivars of classes/modules · ruby/ruby@acb2345](https://github.com/ruby/ruby/commit/acb23454e57e1bbe828e7f3114430cab2d5db44c)

OK

> [Sync did_you_mean · ruby/ruby@e22d293](https://github.com/ruby/ruby/commit/e22d293e06966733e71a7fd9725eee06c03d0177)
> [Revert "Sync did_you_mean" · ruby/ruby@22249bb](https://github.com/ruby/ruby/commit/22249bbb371d794c0330c1a4512f2581c1040297)
> [Sync did_you_mean again · ruby/ruby@66df18c](https://github.com/ruby/ruby/commit/66df18c55e929de4d133cd9e71807a70de392ec0)
> [Remove the test for DYM's verbose formatter · ruby/ruby@905be49](https://github.com/ruby/ruby/commit/905be49bf6b83f7dedb555f3f897f669cb16f1ad)
> [Disable did_you_mean in TestPatternMatching · ruby/ruby@93badf4](https://github.com/ruby/ruby/commit/93badf47704eece8b7a2b084f18a03a9083fb1a8)
> [Sync did_you_mean · ruby/ruby@e353bcd](https://github.com/ruby/ruby/commit/e353bcd1113187185e06eac64b5f63956c30e2d9)

【仕様変更】
DidYouMean関連のrequireで警告が出るようになりました。

- `require 'did_you_mean/formatters/plain_formatter'`
  - 代わりに `require 'did_you_mean/formatter'` としてください。
- `require 'did_you_mean/formatters/verbose_formatter'`
  - 削除されました。

#### [ruby-trunk-changes 2021-10-24 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211024)

> [[ruby/csv] Changed line ending handling to consider the combination \… · ruby/ruby@7f3dd60](https://github.com/ruby/ruby/commit/7f3dd601c895354c041988251a0be05a8a423664)

【仕様変更】
影響の有無が判断できないのですが、CSV.parseなどのCSVを解析する処理のうち、ダブルクオーテーションの対応がとれていないというような問題のある行の処理において、改行の正規表現が間違っていて CR のみ or LF のみとしていたので CR + LF が追加されました。
通常のケースだと CR + LF をうまく扱えているので、問題となるケースは特殊なものだと思います。

テストケースをみると `"2",""NOT" OK"\r\n` のようにダブルクオーテーションの対応が取れていないものでかつ、行末が\r\nの場合に問題だったようです。

```ruby
require "csv"

data = <<-CSV
"1","OK"\r
"2",""NOT" OK"\r
"3","OK"\r
CSV
csv = CSV.new(data)

# - - -
# ruby 2.7.3での挙動です。3行なはずが4行でエラーから復帰できません。
csv.shift
#=> ["1", "OK"]

csv.shift
#=> CSV::MalformedCSVError (Any value after quoted field isn't allowed in line 2.)

csv.shift
#=> CSV::MalformedCSVError (New line must be <"\r"> not <"\n"> in line 3.)

csv.shift
#=> CSV::MalformedCSVError (New line must be <"\r"> not <"\n"> in line 4.)

# - - -
# ruby trunkでの挙動です。全部で3行、エラーから復帰できています。
csv.shift
#=> ["1", "OK"]

csv.shift
#=> CSV::MalformedCSVError (Any value after quoted field isn't allowed in line 2.)

csv.shift
#=> ["3", "OK"]
```

いちおう仕様変更としておきます。

> [[ruby/csv] Add support for Ractor (https://github.com/ruby/csv/pull/218) · ruby/ruby@ee948fc](https://github.com/ruby/ruby/commit/ee948fc1b4cb1ad382beee709008bb93b8f6ba75)

【仕様変更】
まず問題ないと思いますが、CSV::Parser のクラス変数 `@@string_scanner_scan_accept_string` が定数 `STRING_SCANNER_SCAN_ACCEPT_STRING` に変わりました。
これもいちおう仕様変更に挙げます。

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

変更なし

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-10-22](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-22)

日本語の解説: [rails commit log流し読み(2021/10/22) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/23/044703)

> [Enable eager loading by default on CI systems by byroot · Pull Request #43508 · rails/rails](https://github.com/rails/rails/pull/43508)

OK: generator
rails newで新しくプロジェクトを作成したときに環境変数CIが設定されていたら自動テストでEager loadingが有効になりました。地味に便利です。

> [ActionCable Client ensures subscribe command is confirmed. by spinosa · Pull Request #43507 · rails/rails](https://github.com/rails/rails/pull/43507)

OK: レースコンディションで発生する ActionCable のバグ修正。

[ActionCable client ensures subscribe command is confirmed. by spinosa · Pull Request #41581 · rails/rails](https://github.com/rails/rails/pull/41581) のRails 6.1.4へのバックポートです (ブログ記事を書くようになってから初めてです。正直、ワクワクしています)。

具体的には [ActionCable: Sporadically not receiving confirmation for (re)subscription to same channel · Issue #38668 · rails/rails](https://github.com/rails/rails/issues/38668) のバグ修正になります。リリースするほどのものではないため、 6.1.5 はまだリリースされないでしょうね。

#### [Pull requests · rails/rails 2021-10-23](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-23)

日本語の解説: なし

> [Fix `nill` typo in the Upgrade Guide for Rails 7. by connorshea · Pull Request #43514 · rails/rails](https://github.com/rails/rails/pull/43514)

OK: doc

> [Typo: subject-verb agreement in guide by kwiliarty · Pull Request #43513 · rails/rails](https://github.com/rails/rails/pull/43513)

OK: doc

#### [Pull requests · rails/rails 2021-10-24](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-24)

日本語の解説: [rails commit log流し読み(2021/10/24) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/25/043836)

なし

{% include advertisements.html %}

## 今回のおまけ

[永久保存版！？伊藤さん式・Railsアプリのアップグレード手順 - Qiita](https://qiita.com/jnchito/items/0ee47108972a0e302caf) 経由で [RailsDiff](https://railsdiff.org/) を知りました。Rails の各バージョンで rails new した内容を比較できるサイトです。

例えば、 [https://railsdiff.org/6.0.4.1/6.1.4.1](https://railsdiff.org/6.0.4.1/6.1.4.1) のように 6.0系の最新と 6.1系の最新のものを比較してバージョンアップの際の問題点を予想することができます。

rails-diff の実装言語は TypeScript、フレームワークは Ember を使っています。どうやって rails newのdiffを生成しているか気になったので調べました。
なんと [レポジトリ](https://github.com/railsdiff/railsdiff) にはデータが一切ありません。

実は、別のレポジトリ [railsdiff/rails-new-output](https://github.com/railsdiff/rails-new-output) に各バージョンの rails new の結果があります。各バージョンにタグがついていて、 `https://github.com/railsdiff/rails-new-output/compare/v7.0.0.alpha1...v7.0.0.alpha2` の結果と同じものを GitHub の API 経由でとってきて整形して表示しているだけでした。

やりますね。GitHub の機能をうまく使っています。
