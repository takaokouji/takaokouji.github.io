---
layout: single
title:  "【定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-11-07)"
categories: input
tags: ruby rails
toc: true
last_modified_at: 2021-11-08T23:23:01:54+0900
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

- `Enumerable#to_a` にキーワード引数を指定した場合
- 'net/http'
  - 以下の定数がdeprecated
  - `Net::ProxyMod`
  - `Net::NetPrivate::HTTPRequest`
  - `Net::HTTPSession`
  - `Net::HTTPInformationCode`
  - `Net::HTTPSuccessCode`
  - `Net::HTTPRedirectionCode`
  - `Net::HTTPRetriableCode`
  - `Net::HTTPClientErrorCode`
  - `Net::HTTPFatalErrorCode`
  - `Net::HTTPServerErrorCode`
  - `Net::HTTPResponseReceiver`
  - `Net::HTTPResponceReceiver`

以下、変更点の詳細です。

### ruby trunk

#### [ruby-trunk-changes 2021-11-05 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211105)

> [[ruby/net-http] Reset keep_alive timer on new connection · ruby/ruby@5f2c4e3](https://github.com/ruby/ruby/commit/5f2c4e344dc2f19aab54523ae418800b08adaa61)

OK: これはすごい！

10年前に導入された `@last_communicated` に起因するバグ修正。Net::HTTPの `keep_alive` の時間測定が間違ってしまう可能性があったとのことで、よく見つけてくださいました。

> [[ruby/net-http] Fix the typo in a constant name · ruby/ruby@b49dbe0](https://github.com/ruby/ruby/commit/b49dbe025f27a5024c579d3b690833ae8943d71d)
> [[ruby/net-http] Warn deprecated old constants · ruby/ruby@3d8e1ee](https://github.com/ruby/ruby/commit/3d8e1ee40f4aa780243458ee0e527807b948c8fd)

【仕様変更】
問題ないとは思いますが、2001年からタイプミスだった `Net::HTTPResponceReceiver` を deprecated とし、タイプミスを修正した `Net::HTTPResponseReceiver` が追加されました。

また、以下の古い定数も合わせて deprecated になりました。(結局↑の `Net::HTTPResponseReceiver` も deprecated になってしまった)

- `Net::ProxyMod`
- `Net::NetPrivate::HTTPRequest`
- `Net::HTTPSession`
- `Net::HTTPInformationCode`
- `Net::HTTPSuccessCode`
- `Net::HTTPRedirectionCode`
- `Net::HTTPRetriableCode`
- `Net::HTTPClientErrorCode`
- `Net::HTTPFatalErrorCode`
- `Net::HTTPServerErrorCode`
- `Net::HTTPResponseReceiver`

以上の定数を使っているか要チェック。

#### [ruby-trunk-changes 2021-11-06 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211106)

> [Delegate keywords from Enumerable#to_a to #each · ruby/ruby@e83c02a](https://github.com/ruby/ruby/commit/e83c02a768af61cd0890a75e90bcae1119d8bd93)

【仕様変更】
`Enumerable#to_a` にキーワード引数を指定したときにruby 2.4はdelegate、ruby 2.7はdelegateするが警告、ruby 3.0はArgumentErrorとなっていた不具合を修正。ナイス！
ruby 3.0からは仕様変更ですが、さすがにArgumentErrorだったものを修正したので影響はないはずです。とはいえ、いちおうto_aの引数を要チェック。

#### [ruby-trunk-changes 2021-11-07 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211107)

OK

### ruby 3.0

> [merge revision(s) a4d5ee4f31bf3ff36c1a8c8fe3cda16aa1016b12: [Backport… · ruby/ruby@75e7499](https://github.com/ruby/ruby/commit/75e74993916e9abda1a74164fed5b59fc3d9b7ce)

OK: TracePointのメモリリークの修正

> [merge revision(s) d0a05fd4b40ff0f88728c4897e67b68185128f54: · ruby/ruby@6d540c1](https://github.com/ruby/ruby/commit/6d540c1b9844a5832846618b53ce35d12d64deac)

OK: テストの修正のみ

### ruby 2.7

変更なし。

{% include advertisements.html %}

## Rails

### Railsの仕様変更の一覧

#### rails 7.0

- ActiveJob
  - `ActiveJob::TestHelper#assert_enqueued_with` のメッセージ

以下、変更点の詳細です。

### [Pull requests](https://github.com/rails/rails/pulls)

#### [Pull requests · rails/rails 2021-11-05](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-05)

日本語の解説: [rails commit log流し読み(2021/11/05) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/06/045042)

> [Replace CSS references with inline basics for scaffolds by dhh · Pull Request #43597 · rails/rails](https://github.com/rails/rails/pull/43597)

OK: scaffoldのテンプレートの修正

> [Fix has_many inversing recursion on models with recursive associations by gmcgibbon · Pull Request #41552 · rails/rails](https://github.com/rails/rails/pull/41552)

【仕様変更】
`Rails.application.config.active_record.has_many_inversing` が true のときでかつ、以下のような association が定義されている場合に期待通りに動作するようになっています。

```ruby
class Branch
  has_many :branches
  belongs_to :branch, optional: true
end
```

`Rails.application.config.active_record.has_many_inversing` が true のときは要チェック。

#### [Pull requests · rails/rails 2021-11-06](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-06)

日本語の解説: [rails commit log流し読み(2021/11/06) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/07/044714)

マージされたPRなし。

#### [Pull requests · rails/rails 2021-11-07](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-11-07)

日本語の解説: [rails commit log流し読み(2021/11/07) - なるようになるブログ](https://y-yagi.hatenablog.com/entry/2021/11/08/044025)

> [fix typo of using where instead of were by dorianmariefr · Pull Request #43607 · rails/rails](https://github.com/rails/rails/pull/43607)

【仕様変更】
`ActiveJob::TestHelper#assert_enqueued_with` の assert に失敗したときのメッセージのタイプミスを修正。 `where` を `were` にしています。
このメッセージをチェックしているようなテストコードはないと思いますが、いちおう `assert_enqueued_with` を使っているかをチェック！

{% include advertisements.html %}

## 今回のおまけ

[大江戸Ruby会議09出前Edition](https://asakusarb.esa.io/posts/1057)にて、[過去のRubyKaigiの講演動画](https://www.youtube.com/channel/UCBSg5zH-VFJ42BGQFk4VH2A/playlists) が公開されました。

これはすごいですね。
全部をみるのは難しいので、まずはまつもとさんのキーノートをおっかけてみようと思います。
