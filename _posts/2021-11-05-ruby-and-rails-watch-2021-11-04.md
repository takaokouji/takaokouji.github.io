---
layout: single
title:  "【定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-11-04)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-11-05T23:23:23:11+0900
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

- openssl
  - OpenSSL::SSL::SSLSocket
- rubygems
  - gem server サブコマンド
  - gem fetch サブコマンド

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-11-01 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211101)

> [[ruby/openssl] ssl: disallow reading/writing to unstarted SSL socket · ruby/ruby@1ac7f23](https://github.com/ruby/ruby/commit/1ac7f23bb8568b41e511bbe5dfc85c141cc8b2c2)

【仕様変更】
とても良さそうなバグ修正。でも、手元で `SSL session is not started yet.` の警告が出ている場合、この修正によって `OpenSSL::SSL::SSLError` 例外が挙がるようになります。そのため、要チェックです。

#### [ruby-trunk-changes 2021-11-02 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211102)

> [Removed the related code of `gem server` · ruby/ruby@4a39167](https://github.com/ruby/ruby/commit/4a39167260fbd0e8accf42ef7dee27ae73159f8f)

【仕様変更】
gem server サブコマンドがそのままでは使えなくなりました。使いたければ rubygems-server gemをインストールする必要があります。

#### [ruby-trunk-changes 2021-11-03 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211103)

> [[rubygems/rubygems] Fix `gem install` vs `gem fetch` inconsistency · ruby/ruby@c5224c7](https://github.com/ruby/ruby/commit/c5224c71aeba147a111131c16688a208c161ee75)

【仕様変更】
`gem fetch` でインストールするgemのバージョンを `gem install` と一致するようにしたとのこと。
問題ないでしょうけど、 `gem fetch` を使っている方は要チェックです。

#### [ruby-trunk-changes 2021-11-04 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211104)

OK

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

#### rails 7.0

- ActiveRecord
  - `update_all`
  - `delete_all`
- ActiveSupport
  - `ActiveSupport::Dependencies.autoload_paths`

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-11-01](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-01)

日本語の解説: [rails commit log流し読み(2021/11/01) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/02/044852)

> [Extract AbstractAdapter#schema_version by matthewd · Pull Request #43578 · rails/rails](https://github.com/rails/rails/pull/43578)

OK: ActiveRecord::ConnectionAdapters::AbstractAdapter#schema_versionの追加

今後は `migration_context.current_version` の代わりにこちらを使ってほしいそうです。

> [remove removed seamless attribute by dorianmariefr · Pull Request #43569 · rails/rails](https://github.com/rails/rails/pull/43569)

OK: ブラウザが対応していないから iframe の seamless フラグを外したようです。

で、 `railties/lib/rails/templates/rails/mailers/email.html.erb` の用途がわかりませんでした。何に使っているんでしょうかね？

> [Allow group_by and having with update_all by ignacio-chiazzo · Pull Request #43465 · rails/rails](https://github.com/rails/rails/pull/43465)

【仕様変更】
update_all の機能追加で、レシーバの relation に HAVING と GROUP BY が指定できるようになったというものです。ナイス！

いちおう update_all を使っている場合は HAVING と GROUP BY が効くようになるためレシーバを要チェック！

#### [Pull requests · rails/rails 2021-11-02](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-02)

日本語の解説: [rails commit log流し読み(2021/11/02) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/03/045258)

> [Optimize CurrentAttributes method generation by casperisfine · Pull Request #43584 · rails/rails](https://github.com/rails/rails/pull/43584)

OK: 性能改善。

`ActiveModel::ActiveModel.alias_attribute`, `ActiveModel::ActiveModel.define_attribute_methods`, `ActiveModel::ActiveModel.define_attribute_method` が対象です。
`ActiveSupport::CodeGenerator` が追加されています。これ、結構便利な気がします。こういうのを作れるのがすごいですね。

> [Use nested queries when doing DELETE and GROUP_BY and HAVINAG clauses… by ignacio-chiazzo · Pull Request #43580 · rails/rails](https://github.com/rails/rails/pull/43580)

【仕様変更】
delete_all の機能追加で、レシーバの relation に HAVING と GROUP BY が指定できるようになったというものです。update_all と同様の修正ですね。

いちおう delete_all を使っている場合は HAVING と GROUP BY が効くようになるためレシーバを要チェック！

> [Remove glob pattern from app/channels load path by mctaylorpants · Pull Request #43570 · rails/rails](https://github.com/rails/rails/pull/43570)

【仕様変更】
`app/channels` 以下のファイルが `ActiveSupport::Dependencies.autoload_paths` に追加されてしまうという不具合の修正です。
さすがにこれに依存したコードはないと思いたいのですが、 `app/channels` 以下にファイルがある場合は要チェックです。

> [Improve active_job test_helper error messages by HParker · Pull Request #43554 · rails/rails](https://github.com/rails/rails/pull/43554)

OK: active_job test_helperのエラーメッセージに情報を追加しています。すごくよくなっています。ナイス！

#### [Pull requests · rails/rails 2021-11-03](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-03)

日本語の解説: [rails commit log流し読み(2021/11/03) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/04/045026)

> [Add accepts_nested_attributes_for support for delegated_type by xtr3me · Pull Request #41717 · rails/rails](https://github.com/rails/rails/pull/41717)

OK: `accepts_nested_attributes_for` で `delegated_type` を指定できるようになりました！

余談ですが、 dhh が `accepts_nested_attributes_for` にコメントしていたので「おぉ！」ってなりました。`accepts_nested_attributes_for` は嫌いとか、使いたくないというコンテキストで、DHHもそう言ってたとよく見かけたからです。

#### [Pull requests · rails/rails 2021-11-04](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-04)

日本語の解説: [rails commit log流し読み(2021/11/04) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/05/044110)

マージされたPRはありませんでした。

{% include advertisements.html %}

## 今回のおまけ

[Rails 7.0でアセットパイプラインはどう変わるか | Wantedly Engineer Blog](https://www.wantedly.com/companies/wantedly/post_articles/354873)
> Railsでフロントエンドを書くための選択肢について、その歴史と実装を踏まえて比較検討します。

この記事すごいです。永久保存版だと思います。
著者は5.x系からRailsを触り始めたとあるのですが、それ以前の情報もしっかり調査して記述してあります。ほんとにすごい。感謝！
