---
layout: single
title:  "【不定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-10-21)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-10-23T00:00:22:14+0900
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

- test-unit で data を使っていて、さらにオプションで keep: true を使っている場合の挙動
- 重複するキーを持つhashリテラル
- Refinment ( `refine do ~ end` ) のブロック中にモジュールをincludeやprependしている場合の挙動

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-10-18 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211018)

> [Update bundled_gems at 2021-10-18 · ruby/ruby@9d2abb8](https://github.com/ruby/ruby/commit/9d2abb8e924158d0324dd3790dd457dc984eddf2)

【仕様変更】
test-unit が 3.4.8 から 3.5.0 になっていたので変更点を確認しました。
[Commits · test-unit/test-unit](https://github.com/test-unit/test-unit/commits/3.5.0)

dataメソッドの機能追加とバグ修正。バグ修正のほうはdataの最後にkeep:trueがなければ、それ以外のkeep:trueも無視されていたので、無視されないように修正しています。

keep: trueの挙動は [Ruby 2.6.0とtest-unitとデータ駆動テスト - 2018-12-26 - ククログ](https://www.clear-code.com/blog/2018/12/26.html) が詳しいです。これまで使ったことがなかったので知りませんでした。

それで、いちおう仕様変更になると思いますので、 test-unit で dataを使っていて、さらにオプションで keep: true を使っている方は要チェックです。

#### [ruby-trunk-changes 2021-10-19 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211019)

> [Fix evaluation order of hash values for duplicate keys · ruby/ruby@fac2c0f](https://github.com/ruby/ruby/commit/fac2c0f73cafb5d65bfbba7aa8018fa427972d71)

【仕様変更】
まずはこれを見てください。
```ruby
# ruby 2.7.3p183 (2021-04-05 revision 6847ee089d) [x86_64-darwin19]

a = []
# => []

{"a" => a.push(100).last,
 "b" => a.push(200).last,
 "a" => a.push(300).last,
 "a" => a.push(400).last}
# => {"a"=>400, "b"=>200}

a
# => [100, 300, 400, 200]
```

ruby 2.7.3ではhashのキーが重複している場合、hashの値を左から右の順で評価しません。ここでは左から1番目、3番目、4番目、2番目の順になっていて重複するキーがそうでないものよりも先に評価されています。

この修正では、これを左から右の順に評価するように修正しています。

でも、さすがにこの挙動に依存したコードはないと信じたいです。hashリテラルを定義したタイミングでキーの重複に対する警告も出ますからね。

#### [ruby-trunk-changes 2021-10-20 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211020)

OK
debug.gemのバージョンが上がっていますが、ruby 3.1で追加されるようなので差分はチェックしていません。

> [add NEWS entries about debug.gem · ruby/ruby@07b87f7](https://github.com/ruby/ruby/commit/07b87f79797c8716f0ee36f3c32879194717ccd6)
> [NEWS.md: Add error_highlight section · ruby/ruby@7c01cf4](https://github.com/ruby/ruby/commit/7c01cf49083992bc61ec9703b6fb4bc588701c00)

ruby 3.1で新しく bundle されるようになる debug.gem と error_highlight.gem のどちらも楽しみです。

> [Added entries about default gems and bundled gems · ruby/ruby@5322745](https://github.com/ruby/ruby/commit/5322745b29b23d4776345ee5bfa3a976497b49ee)

NEWSが充実してきています。これだけの機能が追加されていて、眺めるだけで楽しくなりますね。

ちょっと気になるのが Language changes に [Fix evaluation order of hash values for duplicate keys · ruby/ruby@fac2c0f](https://github.com/ruby/ruby/commit/fac2c0f73cafb5d65bfbba7aa8018fa427972d71) のハッシュの評価順が変更されることが記述されていないことです。さすがにこれに依存したコードはないだろうから、仕様変更には挙げないということでしょうかね。

#### [ruby-trunk-changes 2021-10-21 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211021)

【仕様変更】
Refinment ( `refine do ~ end` ) に仕様変更がありました。

> [Bug #17429: Prohibit include/prepend in refinement modules - Ruby master - Ruby Issue Tracking System](https://bugs.ruby-lang.org/issues/17429)

ruby 3.1からは以下のコードで警告がでるようになります。

[tomykaira/rspec-parameterized](https://github.com/tomykaira/rspec-parameterized/blob/6ee37a21afe317fe4dac047e6d2fb1ad417e5a56/lib/rspec/parameterized/table_syntax.rb#L27-L61) より
```ruby
    module TableSyntax
      refine Object do
        include TableSyntaxImplement
      end
    end
```

代替手段として、 import_methods が提供されています。上の例だと以下のように書くとそれっぽくなりますが **完全ではありません。**

```ruby
    module TableSyntax
      refine Object do
        import_methods TableSyntaxImplement
      end
    end
```

`import_methods` は対象モジュールのメソッドをコピーします。しかも対象モジュールだけなので、対象モジュールがincludeしているモジュールに定義されているメソッドはコピーしません。

以下が現時点の `import_methods` の制限です。

- Refinement#import raises an ArgumentError if the specified module has methods written in C. Should it import C methods without refinements activation?
- Only methods defined directly in the specified module are imported. Importing ancestors' methods may be confusing because Refinement#import doesn't work with super.

警告が出るだけなので include / prepend はこれまで通り使えます。でも将来的には使えなくなる可能性がありますので、今のうちから代替手段を検討するといいでしょう。

それと、仕様変更ではありませんが、ビッグニュースです！

> [Feature #18229: Proposal to merge YJIT - Ruby master - Ruby Issue Tracking System](https://bugs.ruby-lang.org/issues/18229)

今回 YJIT が取り込まれました 88888888
experimental (実験的) という扱いですが `Kokubun's railsbench` で 16% 速くなったということです。有効にするには ruby を起動するときのコマンドラインオプションに `--yjit` を付けてください。ますます ruby 3.1 が楽しみになりましたね。

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

#### rails 7.0

- selenium-webdriver 3.x が完全にサポート対象外になり、4.0.0以上を使うことになった
- ActiveRecord
  - ActiveRecord::Encryption::MessageSerializer#load
  - ActiveRecord::Base#logger=

以下、変更点の詳細です。

### Pull requests

#### [Pull requests · rails/rails 2021-10-18](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-18)

日本語の解説: [rails commit log流し読み(2021/10/18) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/19/045123)

> [Fixes #43279 by filtering unchanged attributes when default function is available for insert by the-spectator · Pull Request #43296 · rails/rails](https://github.com/rails/rails/pull/43296)

OK
特定の条件( Rails 7 のデフォルト設定 `ActiveRecord::Base.partial_inserts = false` )において、migrationのcolumnのdefaultに関数を指定しても無視されるという不具合を修正して、適切なdefault値が設定されるようになりました。

Rails 7のリリース前に不具合が見つかってよかったですね。

#### [Pull requests · rails/rails 2021-10-19](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-19)

日本語の解説: [rails commit log流し読み(2021/10/19) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/20/044559)

> [Add `ActiveRecord::Base.prohibit_shard_swapping` by seejohnrun · Pull Request #43485 · rails/rails](https://github.com/rails/rails/pull/43485)

OK
`ActiveRecord::Base.prohibit_shard_swapping do ~ end` が追加されました。そのブロック中でshardを切り替えるメソッド( `connected_to_many`, `connecting_to` )を呼び出すと ArgumentError になります。

[activerecord/test/cases/connection_adapters/connection_handlers_sharding_db_test.rb#L255](https://github.com/seejohnrun/rails/blob/32e2a8ef944fb4ae85275ec97d92101e909f8bc4/activerecord/test/cases/connection_adapters/connection_handlers_sharding_db_test.rb#L255) にテストケースがありますが、用途がわかりませんでした。

#### [Pull requests · rails/rails 2021-10-20](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-20)

日本語の解説: [rails commit log流し読み(2021/10/20) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/21/044952)

> [Address `Selenium [DEPRECATION] [:browser_options] :options as a parameter for driver initialization is deprecated.` by yahonda · Pull Request #43496 · rails/rails](https://github.com/rails/rails/pull/43496)

【仕様変更】
この修正で selenium-webdriver 3.x が完全に動作しなくなりました。rails newする場合はまったく問題ないのですが、 rails 7.0 にバージョンアップする場合は要注意です。

> [Validate encrypted message format in Active Record Encryption by jorgemanrubia · Pull Request #43483 · rails/rails](https://github.com/rails/rails/pull/43483)

【仕様変更】
validationの追加。ActiveRecord::Encryption::Errors::Decryption例外が挙がる条件が増えています。シリアライズ対象のデータがハッシュじゃない、またはハッシュに "p" キーがない場合にも例外が挙がります。これも問題ないでしょうけど、いちおう仕様変更とします。

#### [Pull requests · rails/rails 2021-10-21](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-21)

日本語の解説: [rails commit log流し読み(2021/10/21) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/22/044816)

> [Refactor `Process.clock_gettime` uses by casperisfine · Pull Request #43502 · rails/rails](https://github.com/rails/rails/pull/43502)

OK: リファクタリング

> [Rails 7.0 requires selenium-webdriver >= 4.0.0 by kamipo · Pull Request #43498 · rails/rails](https://github.com/rails/rails/pull/43498)

【仕様変更】
selenium-webdriver 3.x がサポート対象外になり、4.0.0以上を使うことになった。
テストを実装するときに問題になる可能性があります。

> [re-add viewport meta tag to application layout by jean-francois-labbe · Pull Request #43490 · rails/rails](https://github.com/rails/rails/pull/43490)

OK: generator
こういう細かい修正もありがたい。Webアプリはこういう風に作るんだよ、というメッセージになりますよね。

> [Reorder layers to be MVC in README.md by grepsedawk · Pull Request #43489 · rails/rails](https://github.com/rails/rails/pull/43489)

OK: doc

### [Ruby / Rails関連の記事一覧｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/category/ruby-rails-related)

#### [週刊Railsウォッチ: Railsリポジトリで進行中のPropshaft、inverse_ofを自動推論ほか（20211018前編）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_10_18/112569)

OK
特に互換性に問題があるような変更点はありませんでした。

> [スコープ付き関連付けでinverse_ofを自動推論](https://techracho.bpsinc.jp/hachi8833/2021_10_18/112569#1-2)
> [RailsリポジトリにあるPropshaft](https://techracho.bpsinc.jp/hachi8833/2021_10_18/112569#2-0)

これらは良さそうですね。早く試してみたい。

> [RSpecのsubject](https://techracho.bpsinc.jp/hachi8833/2021_10_18/112569#2-4)

完全に同意。私も [@jnchito](https://twitter.com/jnchito) さんの Qiitaの記事を読んだことがきっかけで subject はほとんど使わなくなりました (が、それがどの記事だったのかわかりませんでした)。

個人的には、gem で公開するようなライブラリの場合は subject がバチッと決まることが多いのですが、Rails アプリだと subject はなるべく使わないほうが書きやすく、読みやすく、再利用もしやすいです。
そのため、コードをレビューするときにはなるべく「ここは subject にする必要がありますかね？」と確認するようにしています。

#### [Rails 7: ActiveRecord::Base.loggerがclass_attributeで7倍高速化（翻訳）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_10_21/112832)

【仕様変更】
Rails 7 で ActiveRecord::Base.logger が高速化されました！

ただし、

> ActiveRecord::Base.loggerがclass_attributeになったため、@@logger で直接アクセスできなくなります。また、サブクラスに logger = を設定しても親クラスのロガーを変更できません。

という仕様変更があるようです。ActiveRecord::Base のサブクラスで logger を代入している箇所は多くないと思いますが要チェックです。

この記事で知ったのですが、ruby 3.1ではクラス変数の参照がキャッシュされて高速化されるみたいです。ただ関連する Issue の [Feature #17763: Implement cache for cvars - Ruby master - Ruby Issue Tracking System](https://bugs.ruby-lang.org/issues/17763) は未完了となっています。また、 [https://github.com/ruby/ruby/pull/4340#issuecomment-852320817](https://github.com/ruby/ruby/pull/4340#issuecomment-852320817) を読むと revert したとありますが、 ruby の trunk には取り込まれていました。どういうステータスなのでしょうかね？

{% include advertisements.html %}

## 今回のおまけ

今週になって [なるようになるブログ](https://y-yagi.hatenablog.com/) を知りました。なんかすみません。

2014年から Rails の CHANGELOG.md を元に Rails の変更点の日本語解説を続けられてます。

[rails commit log流し読み(2014/04/06) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2014/04/08/084126) より
> 勉強の為に読むようにしていたのだが、折角なのでメモがてらブログに上げてみる。いつまで続くかは怪しい所。

2021-10-21現在、2750以上の記事が公開され、約8年間続けられています。本当にすごい。大先輩です。私もがんばりたいと思います。
