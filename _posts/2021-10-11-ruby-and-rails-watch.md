---
layout: single
title:  "【不定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-10-10)"
categories: output
tags: ruby rails
toc: true
last_modified_at: 2021-10-11T02:02:11:11+0900
---
Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) 、Rails の最新情報は [TechRacho｜BPS株式会社のRuby on Rails開発情報サイト](https://techracho.bpsinc.jp/) が [週刊Railsウォッチの記事一覧｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/tag/%e9%80%b1%e5%88%8arails%e3%82%a6%e3%82%a9%e3%83%83%e3%83%81) で公開してくださっています。両記事ともに大変有益な情報です。ありがたいことです。

本記事ではそれらの情報を元に、Ruby と Rails を安定して使い続けるために Ruby と Rails の変更点がバージョンアップするときに問題になるかどうかという観点で情報をまとめています。

{% include advertisements.html %}

## Ruby

### [ruby-trunk-changes 2021-10-10 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211010)

> 標準添付ライブラリ reline のバージョンを 0.2.8.pre.11 に更新しています。

0.2.8.pre.10から0.2.8.pre.11になっている。
変更点は https://github.com/ruby/reline/compare/v0.2.8.pre.10...v0.2.8.pre.11 から確認できます。

- 影響が少なそうなので変更点はチェックしていません。

> irb のバージョンを 1.3.8.pre.11 に更新しています。

1.3.8.pre.10から1.3.8.pre.11になっている。
変更点は https://github.com/ruby/irb/compare/v1.3.8.pre.10...v1.3.8.pre.11 から確認できます。

- 影響が少なそうなので変更点はチェックしていません。

> gems/bundled_gems の net-smtp のバージョンを 0.2.2 に更新しています。

0.2.1から0.2.2になっている。
変更点は https://github.com/ruby/net-smtp/compare/v0.2.1...v0.2.2 から確認できます。

- 【仕様変更?】[Net::SMTP.start() and #start() accepts ssl_context_params keyword arg… · ruby/net-smtp@4213389](https://github.com/ruby/net-smtp/commit/4213389c21868da5d81e636303dcaf6f29bf2eae?branch=4213389c21868da5d81e636303dcaf6f29bf2eae&diff=unified)
  - これが主な変更点かもしれない。startは引数を追加だけだが、`SMTP.default_ssl_context` は引数の扱いが変わっている。仕様変更かもしれないが、`OpenSSL::SSL::SSLContext#set_params` に true を渡したときの挙動次第。Net::SMTPを使っていないため、調査はここまで。
- [Add response to SMTPError exceptions · ruby/net-smtp@16be09a](https://github.com/ruby/net-smtp/commit/16be09a60c77bcf7ce10fa91cc3689c0d11b0f4b)
  - SMTPサーバーからのレスポンスを返すSMTPError#responseを追加。

## Rails

参考情報: [2021-10-04 ~ 2021-10-10にRailsにマージされたPR](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-04..2021-10-10)

### [週刊Railsウォッチ: ruby/debug 1.2.0リリース、Railsにはthorが入っている、tendejitほか（20211006後編）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_10_06/112178)

Rails以外の記事だったので省略。

### [週刊Railsウォッチ: Rails 7でbyebugがruby/debugに変更、GitHub Codespacesをサポートほか（20211004前編）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_10_04/112129)

> [ByeBugがruby/debugに置き換わる](https://techracho.bpsinc.jp/hachi8833/2021_10_04/112129#1-1)

デフォルトが ruby/debug になるだけなので、既存のRailsアプリへの影響はない。なお、debug gemはruby 2.6以降で使えるようです。

> [PostgreSQLのgenerated columnがサポート](https://techracho.bpsinc.jp/hachi8833/2021_10_04/112129#1-2)

これは便利そう。詳しくは↑の記事をみてください。

> [Railsで生成されるイニシャライザファイルを削減](https://techracho.bpsinc.jp/hachi8833/2021_10_04/112129#1-3)

【仕様変更】 [Generate less initializers in new/upgraded Rails apps by ghiculescu · Pull Request #42538 · rails/rails](https://github.com/rails/rails/pull/42538) を読んだところ、 cookie のマーシャルのデフォルトが変わったので、既存のアプリケーションの設定変更が必要かもしれない。アップグレードに関する説明が追記されている。

[https://github.com/ghiculescu/rails/blob/de238125ef0baab1d1af0f27f61fc700f9e18e55/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_7_0.rb.tt#L48](https://github.com/ghiculescu/rails/blob/de238125ef0baab1d1af0f27f61fc700f9e18e55/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_7_0.rb.tt#L48) より

```ruby
# If you're upgrading and haven't set `cookies_serializer` previously, your cookie serializer
# was `:marshal`. Continue to use that for backward-compatibility with old cookies.
# If you have configured the serializer elsewhere, you can remove this.
#
# To convert all cookies to JSON, use the `:hybrid` formatter.
# If you're confident all your cookies are JSON formatted, you can switch to the `:json` formatter.
#
# See https://guides.rubyonrails.org/action_controller_overview.html#cookies for more information.
# Rails.application.config.action_dispatch.cookies_serializer = :marshal
```

> [Turbo + import mapと互換性のあるCSP設定情報を追加](https://techracho.bpsinc.jp/hachi8833/2021_10_04/112129#1-5)

[https://github.com/rails/rails/pull/43227/files](https://github.com/rails/rails/pull/43227/files) より
【仕様変更】もしCSPの設定を行っている場合は、設定が追加されたり、設定方法が少し変わったりしているので、変更点を確認したほうがいい。
