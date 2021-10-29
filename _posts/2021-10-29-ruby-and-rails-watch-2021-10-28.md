---
layout: single
title:  "【不定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-10-28)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-10-29T20:20:27:15+0900
---
Ruby と Rails を安定して使い続けるために **最新の Ruby と Rails に対して行われた変更がバージョンアップするときに問題になるかどうか** という観点で情報をまとめています。

情報が多いので時間がない人は [Rubyの仕様変更の一覧](#rubyの仕様変更の一覧) と [Railsの仕様変更の一覧](#railsの仕様変更の一覧) を見てください。

Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) で公開してくださっています。

Rails の最新情報は [Pull requests · rails/rails](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed) でマージされた PR を確認できるのと、[y-yagiさん (@y_yagi) / Twitter](https://twitter.com/y_yagi) が [なるようになるブログ](https://y-yagi.hatenablog.com/) で公開してくださっています。

これらは大変有益な情報です。本当にありがたいことです。

{% include advertisements.html %}

## Ruby

### Rubyの仕様変更の一覧

#### ruby trunk

- OpenSSL::PKey::EC::Point#make_affine! が deprecated
- `Enumerable#each_slice`, `Enumerable#each_cons` とそれを呼び出しているメソッド
- typeprof 0.20.0 が 0.20.1 にバージョンアップ

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-10-25 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211025)

> [[ruby/openssl] pkey/ec: deprecate PKey::EC::Point#make_affine! and ma… · ruby/ruby@555788b](https://github.com/ruby/ruby/commit/555788b62216996686387cdabd54f7fe10161d28)

【仕様変更】
OpenSSL::PKey::EC::Point#make_affine! が deprecated になりました。で、これはなにをするメソッドなんだ？コミットログには実際には使われていないはず、と書いてある。とりあえず仕様変更に挙げるけど影響はなさそう。

> [Fix `Enumerable#each_cons` and `Enumerable#each_slice` to return a re… · ruby/ruby@dfb47bb](https://github.com/ruby/ruby/commit/dfb47bbd17c3c2b8ce17dbafaf62df023b0224b2)

【仕様変更】
`Enumerable#each_slice`, `Enumerable#each_cons` とそれを呼び出しているメソッドが nil を返していたのを receiver をそのまま返すように変更されています。

`Enumerable#each` などと同じようにするためだと想像できますが、 nagachikaさん が以下のコメントをされているのが気になりました。

> 少し探したんですが対応するチケットがないみたいでした。

なにきっかけで修正しようと思ったのでしょうかね。それなりに影響ありそうな修正なので。

> [Update TypeProf to 0.20.1 · ruby/ruby@54379e3](https://github.com/ruby/ruby/commit/54379e3d7d297cc8b3ea61ad98c6cc337dc04882)

【仕様変更】
変更内容がたくさんあるので追いかけることができませんでした。

変更点の詳細はこちら: [typeprof/compare/v0.20.0...v0.20.1](https://github.com/ruby/typeprof/compare/v0.20.0...v0.20.1)

挙動は変わっているのでとりあえず仕様変更としますが、いうても TypeProf なので影響はないでしょう。

#### [ruby-trunk-changes 2021-10-26 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211026)

OK

#### [ruby-trunk-changes 2021-10-27 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211027)

OK

気になったのは以下の機能追加。

> [Add Class#descendants · ruby/ruby@717ab0b](https://github.com/ruby/ruby/commit/717ab0bb2ee63dfe76076e0c9f91fbac3a0de4fd)

Class#descendantsの追加。こういうメソッドが好きです。

> [pack.c: add an offset argument to unpack and unpack1 · ruby/ruby@e5319dc](https://github.com/ruby/ruby/commit/e5319dc9856298f38aa9cdc6ed55e39ad0e8e070)

バイナリを解析するときに使えそう。

#### [ruby-trunk-changes 2021-10-28 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211028)

> [Update TypeProf to 0.20.2 · ruby/ruby@efcf18f](https://github.com/ruby/ruby/commit/efcf18f13ecffe5cdbe74cc532246366f60d7858)

OK
[Comparing v0.20.1...v0.20.2 · ruby/typeprof](https://github.com/ruby/typeprof/compare/v0.20.1...v0.20.2) が変更点。TypeProf は運用には使っていないものだと思うのでOKとしています。

> [Add changes Enumerable#each_cons and each_slice in NEWS [ci skip] · ruby/ruby@d51ba1e](https://github.com/ruby/ruby/commit/d51ba1e1be3ecbe5a02e4463f151e178de1c2a6e)

OK
[Fix Enumerable#each_cons and each_slice to return a receiver by MakeNowJust · Pull Request #1509 · ruby/ruby](https://github.com/ruby/ruby/pull/1509) でも書かれていますが、なぜその変更をしたのか？って疑問に思いますよね。バグだから直したってのはリリースしてしばらく立つと賛同をえにくいのでしょうかね。

今回は戻り値が変更になるだけで、元々 nil が返っていたので多くの場合に問題ないと判断できるものでしたね。

[このコメント](https://github.com/ruby/ruby/pull/1509#pullrequestreview-787619461) で知ったのですが knu さんが元々の `Enumerable#each_cons and each_slice` の author だったのですね。感謝。

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

#### rails trunk

- ActiveRecord
  - `ActiveRecord::QueryLogs#with_tag`
  - `ActiveRecord::QueryLogs#update_context`
- Railties
  - 自動テストのrailsメソッド
- ActiveSupport
  - `ActiveSupport::DescendantsTracker.direct_descendants`
  - `ActiveSupport::DescendantsTracker#direct_descendants`

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-10-25](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-25)

日本語の解説: [rails commit log流し読み(2021/10/25) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/26/050043)

> [[ci skip] Corrected Verb in guide for upgrading ruby on rails by AdityaBhutani · Pull Request #43532 · rails/rails](https://github.com/rails/rails/pull/43532)

OK: doc

> [Enum with strings by elfassy · Pull Request #43529 · rails/rails](https://github.com/rails/rails/pull/43529)

OK: doc & test

> [Better spacing in environments/production.rb file by ytkg · Pull Request #43509 · rails/rails](https://github.com/rails/rails/pull/43509)

OK: generator の coding style

> [Fixes namespaced UUID generation for namespace IDs represented as strings by erichmachado · Pull Request #37682 · rails/rails](https://github.com/rails/rails/pull/37682)

OK:  `Digest::UUID.uuid_from_hash` のバグ修正

`config.active_support.use_rfc4122_namespaced_uuids=` に true を設定したときだけバグ修正後の挙動になります。そのため既存のものへの影響はありません。
とはいえ、 `Digest::UUID.uuid_v5(Digest::UUID::DNS_NAMESPACE, "www.widgets.com")` のように namespace 引数を指定している箇所は思わぬ不具合があるかもしれませんので要チェックです。

#### [Pull requests · rails/rails 2021-10-26](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-26)

日本語の解説: [rails commit log流し読み(2021/10/26) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/27/045334)

> [Link to Host Authorization guides on `blocked_host` page by maaslalani · Pull Request #43542 · rails/rails](https://github.com/rails/rails/pull/43542)

OK: doc

> [Remove with_tag from QueryLogs by keeran · Pull Request #43541 · rails/rails](https://github.com/rails/rails/pull/43541)

【仕様変更】
`ActiveRecord::QueryLogs#with_tag` を削除。同じことを実現するための方法が用意されているため。

代替手段は以下です。

- ActiveRecord の annotate: [Rails6 のちょい足しな新機能を試す91（ActiveRecord annotate編） - Qiita](https://qiita.com/suketa/items/e92eae4dfa65ba1de009)
- `ActiveRecord::QueryLogs#set_context`

> [Add missing punctuations in activerecord CHANGELOG [ci-skip] by taha-husain · Pull Request #43536 · rails/rails](https://github.com/rails/rails/pull/43536)

OK: doc

> [Refactor ActiveRecord::QueryLogs context API by casperisfine · Pull Request #43535 · rails/rails](https://github.com/rails/rails/pull/43535)

【仕様変更】
`ActiveRecord::QueryLogs#update_context` が削除されました。今後は `ActiveRecord::QueryLogs#set_context` を使ってください。

> [Add support for setting the schema/structure dump filepath in the config by eileencodes · Pull Request #43530 · rails/rails](https://github.com/rails/rails/pull/43530)

OK: DB の設定ファイルで `schema_dump` を指定できるようになりました。 shards を使うときに便利です。

#### [Pull requests · rails/rails 2021-10-27](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-27)

日本語の解説: [rails commit log流し読み(2021/10/27) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/28/050029)

> [Revert "Call Executor#wrap around each test" by byroot · Pull Request #43553 · rails/rails](https://github.com/rails/rails/pull/43553)
> [Call Executor#wrap around each test by casperisfine · Pull Request #43546 · rails/rails](https://github.com/rails/rails/pull/43546)

OK: いったん修正されたけど、すぐにrevertされた。

> [Check for default function before attribute changes for partial inserts by etiennebarrie · Pull Request #43545 · rails/rails](https://github.com/rails/rails/pull/43545)

OK: 高速化

> [Properly clear the ActiveRecord::QueryLogs context by casperisfine · Pull Request #43544 · rails/rails](https://github.com/rails/rails/pull/43544)

OK: テスト用の修正

> [Fix STI in available_records causing new instances of records to be loaded from database by octatone · Pull Request #43524 · rails/rails](https://github.com/rails/rails/pull/43524)

OK
[Add `available_records` argument to Associations::Preloader · octatone/rails@2a3f175](https://github.com/octatone/rails/commit/2a3f1757dd61cea4f85da859f6bd0ce7180b62b3#diff-97709b319ca07f6cd3f4d6b8a8c443d0cb3e7487696098be377aa9fa78907a35) で導入した `available_records` が STI だと期待通りに動作していなかったので修正。リリース前にみつかってよかった。

> [Use the native `Class#descendants` if available by byroot · Pull Request #43481 · rails/rails](https://github.com/rails/rails/pull/43481)

OK: ruby 3.1 の `Class#descendants` を使う。対応早すぎ。

#### [Pull requests · rails/rails 2021-10-28](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-28)

日本語の解説: [rails commit log流し読み(2021/10/28) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/10/29/050044)

> [Rebalance Railties tests by casperisfine · Pull Request #43559 · rails/rails](https://github.com/rails/rails/pull/43559)

OK: Rails本体のtestに関する修正

> [Setup bootsnap to speedup TestRunnerTest by casperisfine · Pull Request #43558 · rails/rails](https://github.com/rails/rails/pull/43558)

【仕様変更】
自動テストで rails コマンドを使っている場合に cache (bootsnap) を使うようになっています。自動テストの中で rails メソッドで rails コマンドのテストを行っている場合は問題ないことを確認しましょう。

そもそも rails メソッドの存在を知りませんでした。

> [Call Executor#wrap around each test by casperisfine · Pull Request #43550 · rails/rails](https://github.com/rails/rails/pull/43550)

OK
テストに関する修正。テスト単位で状態をリセットするようになります。よさそうな挙動なのですが `active_support.executor_around_test_case = true` を指定したときだけ有効になるようです。(rails new した場合は有効)

> [Don't `SELECT * FROM information_schema.tables` by cgriego · Pull Request #43549 · rails/rails](https://github.com/rails/rails/pull/43549)

OK: ありがたい修正。

> [Refactor DescendantsTracker to leverage native Class#descendants on Ruby 3.1 by casperisfine · Pull Request #43548 · rails/rails](https://github.com/rails/rails/pull/43548)

【仕様変更】
以下が deprecated になりました。通常は使っていないと思いますが、使っている人は要チェック。といいつつ、GitHubで検索しても使っているケースはヒットしませんでした。
- `ActiveSupport::DescendantsTracker.direct_descendants`
- `ActiveSupport::DescendantsTracker#direct_descendants`

{% include advertisements.html %}

## 今回のおまけ

今読んでいる本は [チームが機能するとはどういうことか ― 「学習力」と「実行力」を高める実践アプローチ](https://amzn.to/3jr8WhE) です。
<iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="https://rcm-fe.amazon-adsystem.com/e/cm?ref=qf_sp_asin_til&t=takaokouji-22&m=amazon&o=9&p=8&l=as1&IS2=1&detail=1&asins=B00N8J1NPQ&linkId=3dd9f32dddf1e7ebab76ec4c31674a87&bc1=000000&amp;lt1=_blank&fc1=333333&lc1=0066c0&bg1=ffffff&f=ifr">
    </iframe>

実は私、縦書きの本が読めないのです。この本が縦書きだと知らなくて買ってしまいました。
字を下まで追いかけていって、目線を上に持っていくときにどの行かわからなくなるんですよね...orz。
いつになったら縦書きの本がすらすら読めるようになるのか。トレーニングも兼ねてがんばります！

(Kindle 版だと縦書きと横書きを変更できたりするのでしょうかね。電子書籍リーダーによってはできたりするのかな？ そうだとしたら紙の書籍を超えていますね)
