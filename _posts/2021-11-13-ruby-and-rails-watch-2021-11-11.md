---
layout: single
title:  "【定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-11-11)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-11-13T00:00:45:06+0900
---
Ruby と Rails を安定して使い続けるために **最新の Ruby と Rails に対して行われた変更がバージョンアップするときに問題になるかどうか** という観点で情報をまとめています。

情報が多いので時間がない人は [Rubyの仕様変更の一覧](#rubyの仕様変更の一覧) と [Railsの仕様変更の一覧](#railsの仕様変更の一覧) を見てください。

Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) で公開してくださっています。

Rails の最新情報は [Pull requests · rails/rails](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed) でマージされた PR を確認できるのと、[y-yagiさん (@y_yagi) / Twitter](https://twitter.com/y_yagi) が [なるようになるブログ](https://y-yagi.hatenablog.com/) で公開してくださっています。

これらは大変有益な情報です。本当にありがたいことです。

{% include advertisements.html %}

## Ruby

### Rubyの仕様変更の一覧

#### ruby trunk (ruby 3.1)

- rb_gc_force_recycle()
- net/http
  - HEAD リクエスト

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-11-08 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211108)

OK

#### [ruby-trunk-changes 2021-11-09 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211109)

> [[Feature #18290] Deprecate rb_gc_force_recycle and remove invalidate_… · ruby/ruby@3094064](https://github.com/ruby/ruby/commit/309406484b98fe0aea55016d8f5971b4e6b91761)

【仕様変更】
`rb_gc_force_recycle()` が deprecated になりました。が、まぁ、使っている人は少ないでしょうね...

#### [ruby-trunk-changes 2021-11-10 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211110)

OK

#### [ruby-trunk-changes 2021-11-11 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211111)

> [revival of must_not_null() · ruby/ruby@33533fa](https://github.com/ruby/ruby/commit/33533fabd54e23bced64a74114ee7786478a6ee7)

OK: revert
2ヶ月前のruby trunkの仕様変更でString処理全般でSEGVが発生することがあったのですが、それを元に戻しています。

> [[ruby/net-http] Send Accept-Encoding header on HEAD method · ruby/ruby@52ab9bb](https://github.com/ruby/ruby/commit/52ab9bbee918c63faad32e3851b162691b984d40)

【仕様変更】
標準添付ライブラリ net/http で HEAD リクエストに Accept-Encoding を設定するように修正。
Accept-Encodingによってレスポンスがかわることもあるかもしれません。HEAD リクエストを送っている場合は要チェックです。

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

#### rails 7.0

- ActiveRecord
  - has_many に proc と through を指定している場合

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-11-08](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-08)

日本語の解説: [rails commit log流し読み(2021/11/08) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/09/044920)

> [CSS processors other than Tailwind require a node-based JavaScript bundler by dhh · Pull Request #43600 · rails/rails](https://github.com/rails/rails/pull/43600)

OK: rails newに関する修正

> [Fix preloading for hmt relations with conditions by apauly · Pull Request #43132 · rails/rails](https://github.com/rails/rails/pull/43132)

【仕様変更】
バグ修正なんだけど、一応、仕様変更とします。

不具合の再現コードはこちら: [ActiveRecord - Preloading a hmt relation ignores class_name option · Issue #43175 · rails/rails](https://github.com/rails/rails/issues/43175)

以下の `special_categories` ように `has_many` に proc を指定している場合は要チェック。
```
  has_many :category_posts
  has_many :categories, through: :category_posts

  has_many :special_categories, -> { where(some_flag: true) }, through: :category_posts, source: :category, class_name: "SpecialCategory"
```

なお、この修正は6.1にもバックポートされています。
6.0系と同じ挙動になり、6.0系から6.1系へのバージョンアップがより楽になりますね。

#### [Pull requests · rails/rails 2021-11-09](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-09)

日本語の解説: [rails commit log流し読み(2021/11/09) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/10/044817)

> [[ci skip] Clarify what 'running a migration' means by ivan-denysov · Pull Request #43622 · rails/rails](https://github.com/rails/rails/pull/43622)

OK: doc

> [Document `tag.attributes` helper [ci-skip] by seanpdoyle · Pull Request #43614 · rails/rails](https://github.com/rails/rails/pull/43614)

OK: doc

#### [Pull requests · rails/rails 2021-11-10](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-10)

日本語の解説: [rails commit log流し読み(2021/11/10) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/11/044711)

> [Extract ActiveSupport::ExecutionContext out of ActiveRecord::QueryLogs by casperisfine · Pull Request #43598 · rails/rails](https://github.com/rails/rails/pull/43598)

OK: refactor

この PR で知ったのですが [Rails standardized error reporting interface · Issue #43472 · rails/rails](https://github.com/rails/rails/issues/43472) にて、標準的なエラーレポートの仕組みが検討されています。オプションを指定するだけでエラーレポートの送信先を Sentry や Airbrake に切り替えることができるようになりそうです。これはイイです！

#### [Pull requests · rails/rails 2021-11-11](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-11)

日本語の解説: [rails commit log流し読み(2021/11/11) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/12/044900)

> [Add a note that index length is supported only by MySQL [skip ci] by fatkodima · Pull Request #43630 · rails/rails](https://github.com/rails/rails/pull/43630)

OK: doc

以下のようにMySQLだとindexのデータ長を指定できるようです。

`add_index(:accounts, [:name, :surname], name: 'by_name_surname', length: {name: 10, surname: 15})`

> [Guide: Fix link to Primary key in Active Record Associations by JuanitoFatas · Pull Request #43628 · rails/rails](https://github.com/rails/rails/pull/43628)

OK: doc

{% include advertisements.html %}

## 今回のおまけ

[Ruby 3.1.0 Preview 1 Released](https://www.ruby-lang.org/en/news/2021/11/09/ruby-3-1-0-preview1-released/)

うれしいですね！

リリースノートに書かれている言語仕様の変更のうち、問題となりそうなものが1つありました (とはいえ、現状だと困るものを修正しただけなので問題となるのはコーナーケースだと思われます)。

> Multiple assignment evaluation order has been changed slightly. [Bug #4443]]
> foo[0], bar[0] = baz, qux was evaluated in order baz, qux, foo, and then bar in Ruby 3.0. In Ruby 3.1, it is evaluated in order foo, bar, baz, and then qux.

↑のように多重代入の評価順が変わりました。

[Bug #4443: odd evaluation order in a multiple assignment - Ruby master - Ruby Issue Tracking System](https://bugs.ruby-lang.org/journals/53937/diff?detail_id=38766) に再現コードがあります。

```ruby
def foo
  p :foo
  []
end

def bar
  p :bar
end

x, foo[0] = bar, 0
```

↑の出力は、ruby 2.6.6 では :bar, :foo の順。
ruby 3.1.0 preview 1では :foo, :bar の順です。
左から順に評価されます。

これによって、以下のようなコードでスワップできるようになるというメリットがあります。obj.foo は配列を返すメソッドとかです。
```ruby
obj, obj.foo = obj.foo, obj
```

逆に **スワップしないことを期待している場合** には問題になります。まったくよい例が思いつきませんが、以下のように、多重代入の左辺と右辺で同じレシーバーのメソッド呼び出しをしていて、なおかつ値がスワップしてほしくない場合です (スワップしてほしくないケースってあるのかな？)。

```ruby
model.attr1, model.attr2 = model.attr2, model.attr1
```

あくまでも問題となる可能性があるだけです。というのも、期待とは異なりスワップしないのですから、このコードはまずいと気がつき、その時点で修正しているでしょう。

ということで、多重代入の評価順は Ruby のバージョンによって変わるため、多重代入の評価順に依存しないようなコードを書くようにしましょう。

とはいえ、多重代入を使うなってことではないため、しれっと古いRubyでは動かないコードを書いてしまいそうだけど、そのようなケースってあるのかな...？
