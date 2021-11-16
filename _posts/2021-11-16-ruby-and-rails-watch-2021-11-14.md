---
layout: single
title:  "【定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-11-14)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-11-16T21:21:57:27+0900
---
Ruby と Rails を安定して使い続けるために **最新の Ruby と Rails に対して行われた変更がバージョンアップするときに問題になるかどうか** という観点で情報をまとめています。

情報が多いので時間がない人は [Rubyの仕様変更の一覧](#rubyの仕様変更の一覧) と [Railsの仕様変更の一覧](#railsの仕様変更の一覧) を見てください。

Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) で公開してくださっています。

Rails の最新情報は [Pull requests · rails/rails](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed) でマージされた PR を確認できるのと、[y-yagiさん (@y_yagi) / Twitter](https://twitter.com/y_yagi) が [なるようになるブログ](https://y-yagi.hatenablog.com/) で公開してくださっています。

これらは大変有益な情報です。本当にありがたいことです。

{% include advertisements.html %}

## Ruby

### Rubyの仕様変更の一覧

仕様変更なし。

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-11-12 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211112)

OK

#### [ruby-trunk-changes 2021-11-14 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211114)

OK

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

仕様変更なし。

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-11-12](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-12)

日本語の解説: [rails commit log流し読み(2021/11/12) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/13/044033)

> [Fixed tiny grammatical mistakes in comments [skip ci] by shunyama · Pull Request #43635 · rails/rails](https://github.com/rails/rails/pull/43635)

OK: comment

> [Add actioncable.js and actioncable.esm.js to gem package. by ytnk531 · Pull Request #43631 · rails/rails](https://github.com/rails/rails/pull/43631)

OK: gemspec

#### [Pull requests · rails/rails 2021-11-13](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-13)

日本語の解説: [rails commit log流し読み(2021/11/13) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/14/060109)

> [Remove non-existing encoding task dependency by st0012 · Pull Request #43624 · rails/rails](https://github.com/rails/rails/pull/43624)

OK: doc

#### [Pull requests · rails/rails 2021-11-14](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-14)

日本語の解説: [rails commit log流し読み(2021/11/14) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/15/044435)

> [button_to: Support `authenticity_token:` option by seanpdoyle · Pull Request #43417 · rails/rails](https://github.com/rails/rails/pull/43417)

OK: 機能追加。
↑の日本語の解説に詳しいことが書いてあります。

> [Support `<form>` elements without `[action]` by seanpdoyle · Pull Request #42051 · rails/rails](https://github.com/rails/rails/pull/42051)

OK: 機能追加。
↑の日本語の解説に詳しいことが書いてあります。

{% include advertisements.html %}
