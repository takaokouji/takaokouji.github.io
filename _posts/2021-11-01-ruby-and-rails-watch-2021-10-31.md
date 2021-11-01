---
layout: single
title:  "【不定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-10-31)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-11-01T21:21:10:15+0900
---
Ruby と Rails を安定して使い続けるために **最新の Ruby と Rails に対して行われた変更がバージョンアップするときに問題になるかどうか** という観点で情報をまとめています。

情報が多いので時間がない人は [Rubyの仕様変更の一覧](#rubyの仕様変更の一覧) と [Railsの仕様変更の一覧](#railsの仕様変更の一覧) を見てください。

Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) で公開してくださっています。

Rails の最新情報は [Pull requests · rails/rails](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed) でマージされた PR を確認できるのと、[y-yagiさん (@y_yagi) / Twitter](https://twitter.com/y_yagi) が [なるようになるブログ](https://y-yagi.hatenablog.com/) と [TechRacho｜BPS株式会社のRuby on Rails開発情報サイト](https://techracho.bpsinc.jp/) が [週刊Railsウォッチの記事一覧｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/tag/%e9%80%b1%e5%88%8arails%e3%82%a6%e3%82%a9%e3%83%83%e3%83%81) で公開してくださっています。

これらは大変有益な情報です。本当にありがたいことです。

{% include advertisements.html %}

## Ruby

### Rubyの仕様変更の一覧

#### ruby 3.0

- openssl 2.2.0 から 2.2.1 にバージョンアップ


以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-10-29 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211029)

OK

#### [ruby-trunk-changes 2021-10-30 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211030)

OK

> [Clarify docs about magic comments placement · ruby/ruby@09bdb43](https://github.com/ruby/ruby/commit/09bdb43567b0ae3c46180073043136ec8ec0f6a2)

これすごくありがたい。自分は知っているけど...をきちんとドキュメント化して他人に伝える気遣い、これ大事。

#### [ruby-trunk-changes 2021-10-31 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211031)

OK

> [Argument forwarding definition without parentheses [Bug #18267] · ruby/ruby@13a9597](https://github.com/ruby/ruby/commit/13a9597c7ca83fced5738e9345660ae6aef87eb7)

以下のようにメソッド定義で `...` を使うときにカッコを省略できるようになりました。こういう修正がサラッとできる nobu さんがすごいです。

```ruby
def call a, ...
  a.nil?(...)
end
```

### ruby 3.0

> [openssl: import v2.2.1 · ruby/ruby@00e89fe](https://github.com/ruby/ruby/commit/00e89fe36b57e2d7c4ea269bc827d9806edef5ed)

【仕様変更】
openssl 2.1.3 のバグ修正と追加でいくつかの修正をしたものが 2.2.1 としてリリースされており、それを ruby 本体にマージしたとのこと。
ruby trunk へのマージはともかくこういったバグ修正も 3.0 に入るのですね。

opensslだとセキュリティホールが気になりますが、そのようなものはなさそうです。

> [* 2021-10-30 [ci skip] · ruby/ruby@7388a4b](https://github.com/ruby/ruby/commit/7388a4b7adc121ea9da088847709e6f0bc66b855)

OK: バージョンのみ

> [Bump patchlevel. · ruby/ruby@c9bc91b](https://github.com/ruby/ruby/commit/c9bc91bf6934d67bb302cd13961beb6870b05c03)

OK: バージョンのみ

> [Bump up zlib version to 2.0.0 · ruby/ruby@e5babb1](https://github.com/ruby/ruby/commit/e5babb16a1cc7f034e15180df0eeaacd17b29a34)

OK: バージョンのみ

> [[ruby/fcntl] Bump up fcntl version to 1.0.1 · ruby/ruby@f96517e](https://github.com/ruby/ruby/commit/f96517ec2b52e68fd425151cb64c3561a6ae854a)

OK: バージョンのみ

> [[ruby/drb] Bump up drb version to 2.0.5 · ruby/ruby@519e3bd](https://github.com/ruby/ruby/commit/519e3bde24ca18489d3327dd369aed815ef84c61)

OK: バージョンのみ

> [Bump patchlevel. · ruby/ruby@5afb947](https://github.com/ruby/ruby/commit/5afb947d724f92cf9c94fcbf331c8d530b8ce710)

OK: バージョンのみ

> [test_gc.rb: relax criterion · ruby/ruby@b1696c8](https://github.com/ruby/ruby/commit/b1696c87d31d30a64c93d7d4d9c948f383a9da11)

OK: testのみ

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

- ActiveRecord
  - whereなどのRangeにFloat::INFINITYのようにinfinity?がtrueの値を指定している場合

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-10-29](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-29)

日本語の解説: [rails commit log流し読み(2021/10/29) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/30/062930)

> [Add :day_format option to date_select by shunichi · Pull Request #43567 · rails/rails](https://github.com/rails/rails/pull/43567)

OK
`date_select` に日付のラベルを指定する `day_format` が追加されました。主な用途は日本のロケールで「10日」のように「日」をつけることです。

`year_format` があるので `day_format` も追加します、ってことだけど、月は `month_format_string` なのですよね。

Rails なら `year_format`, `year_format_format`, `month_format`, `month_format_string`, `day_format`, `day_format_string` のようにすべて対応してもいいかもしれません。
ただ、その場合はどちらも設定されたときの優先度を決めないといけませんし、そのときに警告を出すかどうかも悩みます。かといって `month_format_string` を `month_format` にするのは互換性を壊すのでやってほしくないです。互換性を変えるならRails 7のリリースタイミングだよな〜と思いつつ、なにもしません...

> [ActionMailer: Document delivery_job and deliver_later_queue_name by c960657 · Pull Request #43560 · rails/rails](https://github.com/rails/rails/pull/43560)

OK: doc

`delivery_job` が `deliver_later` を呼び出したときに使われる Job のクラス名で、 `deliver_later_queue_name` がそのキューの名前のようです。

> [Action Cable: use non-deprecated entrypoint for JS package by georgeclaghorn · Pull Request #43556 · rails/rails](https://github.com/rails/rails/pull/43556)

OK: [Output Action Cable JS without transpiling and as ESM by dhh · Pull Request #42856 · rails/rails](https://github.com/rails/rails/pull/42856) の修正漏れ

> [Fix (Inflector::Methods#underscore): small regression by Thornolf · Pull Request #43552 · rails/rails](https://github.com/rails/rails/pull/43552)

OK: v7.0.0.alpha2 のデグレ解消。
`Inflector::Methods#underscore` において `Accountsv2N2Test` が `accountsv2n2_test` になるデグレを解消して `accountsv2_n2_test` となるようにしている。

ナイス！

> [Properly handle impossible cases in (not_)between by fschwahn · Pull Request #43547 · rails/rails](https://github.com/rails/rails/pull/43547)

【仕様変更】
バグ修正でとても良いことなのですが、いちおう挙動が変わるので仕様変更としています。

修正前は以下のように Range の開始が `infinity?` が true となるようなケースですべてのレコード示すリレーションを返していました。これを修正して、すべてにマッチしないリレーションを返すようになりました。

```ruby
user = User.create!(age: 20)
User.where(age: Float::INFINITY..).to_a
#=> [user]
```

これ自体はとても良い修正です。でも、思わぬデグレが起きそうなので、 INFINITY を使っているものがあれば要チェックです。

#### [Pull requests · rails/rails 2021-10-30](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-30)

日本語の解説: [rails commit log流し読み(2021/10/30) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/31/055803)

> [ActionMailer Docs: Include name in from address by matt17r · Pull Request #43572 · rails/rails](https://github.com/rails/rails/pull/43572)

OK: doc

ふむふむ、 `email_address_with_name('notification@example.com', 'Example Company Notifications')` で名前付きのメールアドレスを生成できるのですね。学び。

#### [Pull requests · rails/rails 2021-10-31](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-31)

日本語の解説: [rails commit log流し読み(2021/10/31) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/01/044548)

変更がありませんでした。

{% include advertisements.html %}

## 今回のおまけ

お試しで [Anker Eufy Lumi Dual-Bright Night Light (コンパクトLEDセンサーライト)【どこでも設置可能 / モーションセンサー搭載 / コンパクトサイズ / 3個セット】](https://amzn.to/3GIg2Ik) を買って試していましたが、とても良いので買増することにしました。
<iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="//rcm-fe.amazon-adsystem.com/e/cm?lt1=_blank&bc1=000000&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=takaokouji-22&language=ja_JP&o=9&p=8&l=as4&m=amazon&f=ifr&ref=as_ss_li_til&asins=B08WYV7F8H&linkId=d1875801b2c8b9d59a4e0f4d0ff71c3a"></iframe>

便利ではありますが、反応するまでに1秒弱かかるので少し多めに設置すると良さそうです (だから買い増しです)。
