---
layout: single
title:  "【定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-11-21)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-11-25T00:00:55:17+0900
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

- Dir.globの第2引数
- `Module#{public,private,protected,module_function}` の戻り値
- GC.statの戻り値

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-11-19 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211119)

> [Expect bool as `sort:` option at glob [Feature #18287] · ruby/ruby@89b440b](https://github.com/ruby/ruby/commit/89b440bf724b5e670da0fa31c36a7945a7ddc80f)

【仕様変更】
Dir.globの第2引数にnilを渡すと ArgumentError が発生するようになりました。修正前は nil だとデフォルト値の true 扱いだったため、nil = false だと思っていたら挙動が違って紛らわしかったようです。

また、コミットまでのやりとりがよくなかったようで、修正を横取りしてしまったような感じになっています。 OSS ではよくあることなのですが、個人的な感想としては開発者が楽しくなることが Ruby のモットーだと思いますので、こういったところも考慮していければいいなと思います。Good First Issue 的な感じだったのかな。とはいえ、リリースも近いし、 nobu に任せておけば安心感がありますし...難しい問題ですね。

> [Refactor getclassvariable (#5137) · ruby/ruby@ec574ab](https://github.com/ruby/ruby/commit/ec574ab3453709490b53b5cc761ec158103fe42a)

OK: クラス変数参照のパフォーマンスチューニング。最高です！

> [Make Module#{public,private,protected,module_function} return arguments · ruby/ruby@75ecbda](https://github.com/ruby/ruby/commit/75ecbda438670ec12641d1324d0e81a52ee02e0a)

【仕様変更】
`Module#{public,private,protected,module_function}` の戻り値が変わっています。詳しくは nagachika さんのコメントを参照してください。それらの戻り値を使っているところは要チェック！

> [Anonymous block forwarding allows a method to forward a passed · ruby/ruby@4adb012](https://github.com/ruby/ruby/commit/4adb012926f8bd6011168327d8832cf19976de40)

OK: 機能追加

```ruby
def foo(&)
  bar(&)
end
```

これはおもしろい！無名のブロックとして `&` を指定できるようになりました。

> [support `GC.stat(:time)` take 2 · ruby/ruby@349a179](https://github.com/ruby/ruby/commit/349a1797828a1fa6acc3c0d30a2a24e884d02907)

【仕様変更】
GC.stat の戻り値のハッシュに `time: GC にかかったトータルの時間` が追加されています。アプリケーションではまずないと思いますが、いちおう、GC.statの戻り値を使っている処理は要チェック！

#### [ruby-trunk-changes 2021-11-20 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211120)

OK

#### [ruby-trunk-changes 2021-11-21 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211121)

OK

### ruby 3.0

変更なし。

### ruby 2.7

変更なし。

### ruby 2.6

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

#### rails 7.0.x

- ActionView
  - form_for
- `ActiveRecord::Base.filter_attributes` に指定した属性に関するSQLのログ

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-11-19](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-19)

日本語の解説: [rails commit log流し読み(2021/11/19) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/20/045012)

> [ActiveSupport, fix more race conditions on test/cache - part II by esparta · Pull Request #43675 · rails/rails](https://github.com/rails/rails/pull/43675)

OK: test

これもすごいな〜。レースコンディションによるテストの失敗に対応するのは大変なのですよね。

> [Rails standardized error reporting interface by casperisfine · Pull Request #43625 · rails/rails](https://github.com/rails/rails/pull/43625)

OK: 機能追加

新しく追加される標準のエラー処理の仕組みです。設定によってエラーメッセージをどのサービスに送るのかを変更できるようです。これ使うのが楽しみです！

> [Implement `form_for` by delegating to `form_with` by seanpdoyle · Pull Request #43421 · rails/rails](https://github.com/rails/rails/pull/43421)

【仕様変更】
具体的にどこが変わったのかは確認できていませんが、 `form_for` が内部で `form_with` を呼び出すようになりました。コーナーケースで生成する HTML が変わる可能性が十分にあるため `form_for` を使っている箇所は要チェック！

> [Makes the array syntax consistent with other use cases by sandip-mane · Pull Request #43045 · rails/rails](https://github.com/rails/rails/pull/43045)

OK: リファクタリング

> [Filter attributes in SQL logs by aishbuilds · Pull Request #42006 · rails/rails](https://github.com/rails/rails/pull/42006)

【仕様変更】
SQLのログにおいても、 `ActiveRecord::Base.filter_attributes` に指定した属性をフィルターするようにしています。ありがたい修正。でもログとはいえ仕様がかわるので要チェック！

#### [Pull requests · rails/rails 2021-11-20](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-20)

日本語の解説: [rails commit log流し読み(2021/11/20) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/21/045311)

> [Fix typo in docs by jacobherrington · Pull Request #43679 · rails/rails](https://github.com/rails/rails/pull/43679)

OK: doc

#### [Pull requests · rails/rails 2021-11-21](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-21)

日本語の解説: [rails commit log流し読み(2021/11/21) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/22/044838)

PRなし

{% include advertisements.html %}
