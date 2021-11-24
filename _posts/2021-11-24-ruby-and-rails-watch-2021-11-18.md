---
layout: single
title:  "【定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-11-18)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-11-24T23:23:55:06+0900
---
Ruby と Rails を安定して使い続けるために **最新の Ruby と Rails に対して行われた変更がバージョンアップするときに問題になるかどうか** という観点で情報をまとめています。

情報が多いので時間がない人は [Rubyの仕様変更の一覧](#rubyの仕様変更の一覧) と [Railsの仕様変更の一覧](#railsの仕様変更の一覧) を見てください。

Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) で公開してくださっています。

Rails の最新情報は [Pull requests · rails/rails](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed) でマージされた PR を確認できるのと、[y-yagiさん (@y_yagi) / Twitter](https://twitter.com/y_yagi) が [なるようになるブログ](https://y-yagi.hatenablog.com/) で公開してくださっています。

これらは大変有益な情報です。本当にありがたいことです。

{% include advertisements.html %}

## Ruby

### Rubyの仕様変更の一覧

#### ruby 3.1.x

- rubygems 
- bundler
- Date.parse
- ipaddr
- `Kernel#load`

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-11-15 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211115)

OK

#### [ruby-trunk-changes 2021-11-16 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211116)

> [Enhanced RDoc for Integer (#5118) · ruby/ruby@f31b7f0](https://github.com/ruby/ruby/commit/f31b7f0522e4abfea61f6a74b859205b2b5f8ade)

OK: これは力作。ぜひご覧あれ！

> [Merge the master branch of rubygems repo · ruby/ruby@f3bda89](https://github.com/ruby/ruby/commit/f3bda8987ecf78aa260e697232876b35f83b67c3)

【仕様変更】
upstream の rubygems をマージしています。既存のふるまいは変わっていないように見えるので、 rubygems や bundler の内部処理に依存している場合は要チェック！

#### [ruby-trunk-changes 2021-11-17 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211117)

> [[ruby/date] Add length limit option for methods that parses date strings · ruby/ruby@489c8ce](https://github.com/ruby/ruby/commit/489c8cebf575741d62effd0d212f1319beff3c40)

【仕様変更】
[CVE-2021-41817: Regular Expression Denial of Service Vulnerability of Date Parsing Methods](https://www.ruby-lang.org/en/news/2021/11/15/date-parsing-method-regexp-dos-cve-2021-41817/) に対応するためのようです。 Date.parse に 128 よりも長い文字列を渡している場合は要チェック!

なお、DoS の危険性も理解した上で適用することになりますが、 `Date.parse(str, limit: nil)` とすることで従来と同じ挙動になります。

> [[ruby/ipaddr] Bump version to 1.2.3 · ruby/ruby@ed7a641](https://github.com/ruby/ruby/commit/ed7a6413785cf1c8f4dfef3eca1790818afe7002)

【仕様変更】
ipaddrのバージョンアップに伴い [Comparing v1.2.2...v1.2.3 · ruby/ipaddr](https://github.com/ruby/ipaddr/compare/v1.2.2...v1.2.3) の変更があります。仕様変更もたくさんあります。使っている人は要チェック！

> [[ruby/date] `Date._<format>(nil)` should return an empty Hash · ruby/ruby@fa674cf](https://github.com/ruby/ruby/commit/fa674cf7230e40bc96625ee97a6057e48bb20f0f)

OK: Date.parse 関連の後方互換性の向上。

nil のときに `{}` を返すようになり、後方互換性が上がっています。

> [[ruby/date] check_limit: also handle symbols · ruby/ruby@a87c56f](https://github.com/ruby/ruby/commit/a87c56f820dac90d50544ad33cc546daa9f29a9a)

OK: さらなる Date.parse 関連の後方互換性の向上。ありがたい。

symbol のときも適切に処理するようになりました。

#### [ruby-trunk-changes 2021-11-18 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211118)

> [Allow Kernel#load to load code into a specified module · ruby/ruby@b35b7a1](https://github.com/ruby/ruby/commit/b35b7a1ef25347735a6bb7c28ab7e77afea1d856)

【仕様変更】
おもしろい修正ですね。 nagachika さんもコメントされているように、 true のかわりに Module を指定している場合は挙動が変わるため `Kernel#load` の第2引数を要チェック！

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

### ruby 2.6

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

#### rails 7.0

- ActionView
  - button_to

#### rails 6.1.x

- ActiveSupport
  - ActiveSupport::TimeZone#iso8601

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-11-15](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-15)

日本語の解説: [rails commit log流し読み(2021/11/15) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/16/045911)

> [ActiveSupport: Remove warnings on test/cache/stores by esparta · Pull Request #43652 · rails/rails](https://github.com/rails/rails/pull/43652)

OK: Rails自体の自動テストの修正

> [Fixes for multi-service direct uploads by gmcgibbon · Pull Request #43650 · rails/rails](https://github.com/rails/rails/pull/43650)

OK: ActionTextのDirectUpload時にHTMLのdata-direct-upload-token属性とdata-direct-upload-attachment-name属性を使うようにしています。

> [Fix flaky test in HasManyThroughDisableJoinsAssociationsTest by DmitryTsepelev · Pull Request #43649 · rails/rails](https://github.com/rails/rails/pull/43649)

OK: Rails自体の自動テストの修正

> [docs/guides: true/false typo by ermakovov · Pull Request #43648 · rails/rails](https://github.com/rails/rails/pull/43648)

OK: doc

> [Set the execution context from AC::Metal rather than AbstractController by casperisfine · Pull Request #43646 · rails/rails](https://github.com/rails/rails/pull/43646)

OK: 説明が難しいですが仕様変更ではありません。

> [Improve compatibility with date versions 3.2.1, 3.1.2, 3.0.2 and `2.0.1` by casperisfine · Pull Request #43644 · rails/rails](https://github.com/rails/rails/pull/43644)

【仕様変更】
rails 6.1系の修正です。
ActiveSupport::TimeZone#iso8601 に nil を渡し時の挙動を ruby の date に合わせ、例外を挙げるようにしています。
ruby の同名のメソッドとの互換性を保ってくれるのはとてもいいですね。

とはいえ仕様変更ですので、iso8601 に nil を渡している可能性がある箇所は要チェックです。

> [Call yarn directly by zarqman · Pull Request #43641 · rails/rails](https://github.com/rails/rails/pull/43641)

OK: yarn:installの修正

> [[ci skip] Enrich the introduction for debug gem by st0012 · Pull Request #43621 · rails/rails](https://github.com/rails/rails/pull/43621)

OK: doc

> [Action View: Support `fields model: [...]` by seanpdoyle · Pull Request #43416 · rails/rails](https://github.com/rails/rails/pull/43416)

OK: `form_with` と同様に `fields` でも `fields model: [@nested, @model]` のように model に配列を指定できるようになりました。

> [Make `button_to` more model-aware by seanpdoyle · Pull Request #43413 · rails/rails](https://github.com/rails/rails/pull/43413)

【仕様変更】
`button_to` の第1引数に指定したモデルのインスタンスが DB に保存されているものであれば `http_method` が patch になります。従来は post でした。

`button_to` の引数にモデルのインスタンスを指定していて、なおかつ method オプションを指定していない箇所は要チェック！

> [Introduce `field_name` view helper by seanpdoyle · Pull Request #43409 · rails/rails](https://github.com/rails/rails/pull/43409)

OK: `field_name` メソッドの追加。

これはすごく便利そう。早く使いたい。

> [Enable Lint/DuplicateMethods rubocop rule by nvasilevski · Pull Request #43374 · rails/rails](https://github.com/rails/rails/pull/43374)

OK: Rails自体のrubocopの設定変更

> [Execute `field_error_proc` within view by seanpdoyle · Pull Request #42755 · rails/rails](https://github.com/rails/rails/pull/42755)

OK: config.action_viewにフィールドのエラー処理の設定を追加しています。

これは一見すると便利そうだけど、実際には共通処理にできないことが多いのですよね。エラー処理は複雑です。

> [Support `Object#with_options` without a block by seanpdoyle · Pull Request #42682 · rails/rails](https://github.com/rails/rails/pull/42682)

OK: with_optionsのブロックを省略できるようになりました。

> [Pass service_name param to DirectUploadsController by DmitryTsepelev · Pull Request #38957 · rails/rails](https://github.com/rails/rails/pull/38957)

OK: ActiveStorage の Direct Uploads 対応。

既存機能への影響はなさそう。Direct Uploads は Rails のサーバーを介さずにウェブブラウザから直接 S3 などにファイルをアップロードする機能です。これも早くつかってみたい！

#### [Pull requests · rails/rails 2021-11-16](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-16)

日本語の解説: [rails commit log流し読み(2021/11/16) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/17/044433)

> [Fix a regression in association preloader by TooManyBees · Pull Request #43660 · rails/rails](https://github.com/rails/rails/pull/43660)

OK: rails 7.0でのデグレの修正。リリース前に見つかってよかった。ナイス！

> [Guides: Mention rake routes task by dacook · Pull Request #43632 · rails/rails](https://github.com/rails/rails/pull/43632)

OK: doc

#### [Pull requests · rails/rails 2021-11-17](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-17)

日本語の解説: [rails commit log流し読み(2021/11/17) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/18/044838)

> [[ci skip] Rephrase SQL Injection countermeasure by esparta · Pull Request #43661 · rails/rails](https://github.com/rails/rails/pull/43661)

OK: doc

> [Upgrade `jsbundling-rails` version to support the source maps. by dixpac · Pull Request #43656 · rails/rails](https://github.com/rails/rails/pull/43656)

OK: rails new

> [Fix a NoMethodError in associate_records_from_unscoped by TooManyBees · Pull Request #43636 · rails/rails](https://github.com/rails/rails/pull/43636)

OK: デグレ対応。

[Fix STI in available_records causing new instances of records to be l… · rails/rails@2d988d0](https://github.com/rails/rails/commit/2d988d03fcd5a3952e4fefeed9a8f760e71c37cb) のデグレに対応してくれています。ナイス！

#### [Pull requests · rails/rails 2021-11-18](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-18)

日本語の解説: [rails commit log流し読み(2021/11/18) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/19/050120)

> [ActiveSupport: Fix some race conditions on test/cache/stores by esparta · Pull Request #43670 · rails/rails](https://github.com/rails/rails/pull/43670)

OK: test

これはすごい。たまに落ちるテストの修正。こういうの見つけるのも修正するのも大変。とてもありがたい！

> [Improve language in upgrading guide by brandoncc · Pull Request #43668 · rails/rails](https://github.com/rails/rails/pull/43668)

OK: doc

> [Add automatic shard swapping middleware by eileencodes · Pull Request #43665 · rails/rails](https://github.com/rails/rails/pull/43665)

OK: 機能追加

詳細は y-yagi さんの日本語解説を参照してもらうとして、これを使うのが楽しみです。rails 7が待ち遠しいですね。

> [Introduce `ActiveSupport::IsolatedExecutionState` for internal use by casperisfine · Pull Request #43596 · rails/rails](https://github.com/rails/rails/pull/43596)

OK: 機能追加

アプリケーションの用途によって、一長一短な Thread と Fiber を使い分けられるようにするのはナイスアイデアですね。そういうことを提案できるようになりたいです。

{% include advertisements.html %}
