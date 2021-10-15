---
layout: single
title:  "【不定期配信】最新のRuby & Railsへのバージョンアップ時の注意点 (~ 2021-10-14)"
categories: output
tags: ruby rails
toc: true
last_modified_at: 2021-10-15T23:23:41:57+0900
---
Ruby の最新情報は [nagachikaさん (@nagachika) / Twitter](https://twitter.com/nagachika) が [ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/) 、Rails の最新情報は [TechRacho｜BPS株式会社のRuby on Rails開発情報サイト](https://techracho.bpsinc.jp/) が [週刊Railsウォッチの記事一覧｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/tag/%e9%80%b1%e5%88%8arails%e3%82%a6%e3%82%a9%e3%83%83%e3%83%81) で公開してくださっています。両記事ともに大変有益な情報です。ありがたいことです。

本記事ではそれらの情報を元に Ruby と Rails を安定して使い続けるために最新の Ruby と Rails に対して行われた変更がバージョンアップするときに問題になるかどうかという観点で情報をまとめています。

{% include advertisements.html %}

## Ruby

### 仕様変更の一覧

#### ruby 3.0

- `$LOADED_FEATURES`

{% include advertisements.html %}

### ruby trunk

#### [ruby-trunk-changes 2021-10-11 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211011)

OK
relineの開発が活発ですね。すごい！

> [[ruby/ipaddr] Make IPAddr#include? consider range of argument · ruby/ruby@9a321dd](https://github.com/ruby/ruby/commit/9a321dd9b2fb929873a6b50b41efdf3bd3119536)

OK
`net4 = IPAddr.new("192.168.2.0/16")` みたいにnetmaskを指定できるようになったみたい。

#### [ruby-trunk-changes 2021-10-12 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211012)

OK

#### [ruby-trunk-changes 2021-10-13 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211013)

> [[ruby/digest] Bump version to 3.1.0.pre0 · ruby/ruby@e94bcda](https://github.com/ruby/ruby/commit/e94bcda02539e1695cdda9550ace45c1890e541c)
> [[ruby/digest] Bump version to 3.1.0.pre1 · ruby/ruby@ab787c4](https://github.com/ruby/ruby/commit/ab787c493b99f1c5195ebb7f29e8d5602ecc60f4)
> [[ruby/digest] Bump version to 3.1.0.pre2 · ruby/ruby@01dc55f](https://github.com/ruby/ruby/commit/01dc55ffad7f8b28865d7c1138f92b70348436ff)

OK
digestのバージョンが3.0.1.preから3.1.0.pre2に上がっています。ざっと [修正内容](https://github.com/ruby/digest/commits/master) をみたけど仕様変更はなさそう。JRuby対応とCIに関する修正が主なもの。

#### [ruby-trunk-changes 2021-10-14 - ruby trunk changes](https://ruby-trunk-changes.hatenablog.com/entry/ruby_trunk_changes_20211014)

OK
以下のように標準添付ライブラリのバージョンが更新されています。バージョン番号しか変わっていないような気がしますが、変えるとどのような影響があるのでしょうかね。

- zlib: 1.1.0 から 2.1.0
- json: 2.5.1 から 2.6.0
- fcntl: 1.0.0 から 1.0.1
- benchamark: 0.1.1 から 0.2.0
- cgi: 0.2.0 から 0.3.0
- timeout: 0.1.1 から 0.2.0
- yaml: 0.1.1 から 0.2.0
- find: 0.1.0 から 0.1.1
- nkf: 0.1.0 から 0.1.1
- base64:0.1.0 から 0.1.1

追記: [@nagachika](https://twitter.com/nagachika) さんからのコメント。なるほど！

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">なお標準添付ライブラリのバージョンbumpされてるのは、3.1.0 リリース時に default gems 化されているものは変更点があったらバージョンを上げておかないと、RubyGems で公開されているものと不整合が起きてbundlerでの解決とかsecurity fix時の影響バージョンのアナウンスとかに問題が起きるからかと</p>&mdash; nagachika (@nagachika) <a href="https://twitter.com/nagachika/status/1449020651587604485?ref_src=twsrc%5Etfw">October 15, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

### ruby 3.0

> [merge revision(s) 89242279e61b023a81c58065c62a82de8829d0b3,529fc204af… · ruby/ruby@fe9d33b](https://github.com/ruby/ruby/commit/fe9d33beb78d5c7932a5c2ca3953045c0ae751d5)

OK
修正前は Marshal.load の proc の戻り値に対して freeze すると例外が挙がっていたが、例外が挙がらないようになり freeze できるようになった。

> [merge revision(s) 60d0421ca861944459f52292d65dbf0ece26e38a,b6534691a1… · ruby/ruby@2c947e7](https://github.com/ruby/ruby/commit/2c947e74a0a11fe6c54253c15224dc80054c62a2)

【仕様変更】 
`$LOADED_FEATURES` のエンコーディングをファイルシステムのデフォルトエンコーディングに修正。修正前はエンコーディングが binary になっていたようです。 `$LOADED_FEATURES` を使っている箇所は影響がある。

> [merge revision(s) abc0304cb28cb9dcc3476993bc487884c139fd11: [Backport… · ruby/ruby@cfad058](https://github.com/ruby/ruby/commit/cfad0583eb18bb4505f28ee5cfab703a6b9987be)

OK
Regexp#matchの修正。レースコンディションでのbackrefの改善。互換性あり。

### ruby 2.7

変更なし。

## Rails

### 仕様変更の一覧

#### Rails 7.0

- ActiveRecord / ActiveModel
  - has_secure_password (ActiveModel::SecurePassword)
- ActionText
  - `ActionText::Content#to_plain_text`
- ActiveJob
  - `ActiveJob::Base#perform_now`

{% include advertisements.html %}

### [2021-10-11 ~ 2021-10-14にRailsにマージされたPR](https://github.com/rails/rails/pulls?q=is%3Apr+is%3Aclosed+merged%3A2021-10-11..2021-10-14)

> [Better ActionText plain text output for nested lists by swanson · Pull Request #37976 · rails/rails](https://github.com/rails/rails/pull/37976)

【仕様変更】
ネストしたul、olをうまいことインデントを入れて整形できるようになりました。非互換なので ActionText を使っている人は要チェック。しかし、このPRは 15 Dec 2019 に作成されているため、2年近くたってマージされたのですね。

> [Arel: Add support for FILTER clause (SQL:2003) by Envek · Pull Request #40491 · rails/rails](https://github.com/rails/rails/pull/40491)

OK
Arelの機能追加。以下のようにfilterが記述できる。これが実現できるのがすごいな。MySQLはサポート対象外みたい。

```ruby
Model.all.pluck(
  Arel.star.count.as('records_total').to_sql,
  Arel.star.count.filter(Model.arel_table[:some_column].not_eq(nil)).as('records_filtered').to_sql,
)
```

> [Expand gemspec files within gem directory by chriscz · Pull Request #41934 · rails/rails](https://github.com/rails/rails/pull/41934/files)

OK: generatorの修正

> [Set timestamps on `insert_all`/`upsert_all` record creation by sambostock · Pull Request #43003 · rails/rails](https://github.com/rails/rails/pull/43003)

OK
機能追加。しかし insert_all と upsert_all のときにオプションを指定するとタイムスタンプが更新できるのは良い機能ですね。
ちょっと気になったのは https://github.com/rails/rails/pull/43003/files#diff-3f89af7ff219385718b7c0e4635cc4190476349db18f8bf80fb84fa1e7f5e289R82 に TODO が残っています。

```ruby
# TODO: Consider remaining this method, as it only conditionally extends keys, not always
```

ということで思わぬエラーに遭遇しそう。エラーに遭遇したら PR を作成するチャンスです！

> [Use loaded records where possible when preloading by composerinteralia · Pull Request #43137 · rails/rails](https://github.com/rails/rails/pull/43137)

多くの場合にOK
必要なときのみSELECTを発行する。
多くの場合にOKだけど、こういうのは思わぬときにエラーになるし、もしあればすぐに見つかって修正されるだろう。

> [clear secure password cache if password is set to `nil` by doits · Pull Request #43378 · rails/rails](https://github.com/rails/rails/pull/43378)

【仕様変更】
ActiveRecord(ActiveModel)の属性のpasswordにnilをセットしたとき、修正前はパスワードがクリアされていなかった。キャッシュに残っていた。それをきちんとクリアするようにしている。仕様変更だけど、ナイスな修正！

> [Bump Rake Pin in Railties by nvick · Pull Request #43398 · rails/rails](https://github.com/rails/rails/pull/43398/files)

OK: Rake が0.13から12.2以上になる。

> [Treat html suffix in controller translation by rafaelfranca · Pull Request #43415 · rails/rails](https://github.com/rails/rails/pull/43415)

I18n.translateのかわりにActiveSupport::HtmlSafeTranslation.translateを使う修正。メッセージカタログに文字を埋め込むときにHTMLがエスケープされるようになる。ナイスな修正だけで思わぬ非互換があるかもしれず、またそれを見つけるのは難しい。影響を受けたとしても、潜在的にセキュリティホールになる箇所が解消されたってことで問題ないとする。

> [Address test_does_not_raise_if_no_fk_violations failure by yahonda · Pull Request #43423 · rails/rails](https://github.com/rails/rails/pull/43423)

OK: テストの修正

> [Address action_mailbox bug report templates failures with Ruby3.1.0dev by yahonda · Pull Request #43424 · rails/rails](https://github.com/rails/rails/pull/43424)

OK: doc

> [DOCS: Improve ActionText FixtureSet Ruby docs by seanpdoyle · Pull Request #43425 · rails/rails](https://github.com/rails/rails/pull/43425)

OK: doc

> [Stop failing GSRF token generation when session is disabled by casperisfine · Pull Request #43427 · rails/rails](https://github.com/rails/rails/pull/43427)

OK
修正前は、セッションを無効にしているときにCSRFトークンを受け取るとエラーにしていた。しかし、セッションを無効にしていることを判定することが難しく、意図せずエラーとなってしまった。そこで、「セッションを無効にしているときにCSRFトークンを受け取ったかどうか」のチェックをしないようにした。

なお、↑のチェックは [Explicitly fail on attempts to write into disabled sessions · Shopify/rails@c1c96a0](https://github.com/Shopify/rails/commit/c1c96a014049b2660ce3a89b3c1b7aef072ae922#diff-5f81b06a0e3051b576daee16c960b21e715a6cc26d97d020c546d2fa697c9bc6) で追加されたもの。

チェックしていたものをチェックしないようにしただけなので、バージョンアップへの影響はないでしょう。

> [Bump required digest version to 3.1.0.pre for Ruby 3.1 by yahonda · Pull Request #43433 · rails/rails](https://github.com/rails/rails/pull/43433)

わかんない。
これなんだろう。CIで失敗したので修正。修正内容は net-smtp 0.2.2 (先週 ruby 本体に取り込まれたもの) に依存する digest のバージョンを 3.0.1dev にしたというものだった。ActionMailboxを使っていると同じような問題に遭遇するのかな。

> [Allow `ActiveJob::Base.set` to configure jobs when using `.perform_now` by bensheldon · Pull Request #43434 · rails/rails](https://github.com/rails/rails/pull/43434)

【仕様変更】
`ActiveJob::Base.set` の設定を `perform_now` でも使うようになる。`ActiveJob::Base.set` を利用している場合は挙動が変わる。

> [Raise error when serializing an anonymous class. by VeerpalBrar · Pull Request #43436 · rails/rails](https://github.com/rails/rails/pull/43436)

OK
ActiveJobの引数などのシリアライズをするときに無名クラスや無名モジュールだと例外が挙がるようになった。元々エラーになっていたようなので問題ない。

> [Updated disable_joins examples for has_one through association. by ashiksp · Pull Request #43437 · rails/rails](https://github.com/rails/rails/pull/43437)

OK: doc

> [Add document `config.active_record.verbose_query_logs` into `Configuring Rails Applications` [skip ci] by soartec-lab · Pull Request #43443 · rails/rails](https://github.com/rails/rails/pull/43443)

OK: doc

> [fix: duplicate active record objects on inverse_of by jstncarvalho · Pull Request #43445 · rails/rails](https://github.com/rails/rails/pull/43445)

OK
ActiveRecordの不具合修正。
これが問題になるようなコードはさすがにないだろう。

> [Document new `record_timestamps` option on `insert_all` by sambostock · Pull Request #43446 · rails/rails](https://github.com/rails/rails/pull/43446/files)

OK: doc

> [Fix primary_abstract_class with engines by eileencodes · Pull Request #43447 · rails/rails](https://github.com/rails/rails/pull/43447)

OK: engineのgeneratorのバグ修正。

> [Make inversed association stale after updating id by composerinteralia · Pull Request #43448 · rails/rails](https://github.com/rails/rails/pull/43448)

【仕様変更】
まずはこれをみてほしい。

```ruby
comment = post.comments.first

comment.update!(post_id: some_other_post_id)

# comment.post should now return the post with some_other_post_id, but
# since it was inversed it doesn't go stale and this test fails
refute_equal post, comment.post
```

つまり、あるレコード(post)と関連レコード(post.comments.first)との紐付けを変更する。そのときに関連レコード(comments)から元のレコードを参照する(comment.post)と、紐付けを変更したにもかかわらず、元のレコード(post)を参照できてしまう。
この不具合を修正している。

さすがにこの不具合に依存したコードは少ないだろうけど、思い当たるものはたくさんある。モンキーパッチを仕込んでチェックするとかしないと、影響の有無がわかんないだろうな。

余談: `refute_equal` の存在を知らなかった: [refute_equal (MiniTest::Assertions) - APIdock](https://apidock.com/ruby/MiniTest/Assertions/refute_equal)

[Make ActionDispatch::Routing::RouteWrapper class private since it's o… by ignacio-chiazzo · Pull Request #43451 · rails/rails](https://github.com/rails/rails/pull/43451)

OK: doc

> [Update rubocop example command to include 'bundle exec' by missy-davies · Pull Request #43452 · rails/rails](https://github.com/rails/rails/pull/43452)

OK: doc

> [Use webdriver 4.6.1 or higher to support selenium-webdriver 4.0.0 by yahonda · Pull Request #43456 · rails/rails](https://github.com/rails/rails/pull/43456)

OK: Rails自体のテスト用のseleniumのバージョンを上げただけ。

[Import actiontext.css when actiontext is installed by jacobherrington · Pull Request #43453 · rails/rails](https://github.com/rails/rails/pull/43453)

OK
新しい Rails アプリを生成するときに --css オプションを指定する。そのときに ActionText に関連した css を import するための設定が漏れていたので、 import するように修正している。

[Fix Selenium deprecation warnings in CI. by sabulikia · Pull Request #43459 · rails/rails](https://github.com/rails/rails/pull/43459)

OK: Rails自体のCI

[Add validation for ActiveRecord.default_timezone by leonid-shevtsov · Pull Request #43460 · rails/rails](https://github.com/rails/rails/pull/43460)

OK
ActiveRecord.default_timezoneは :local か :utc しか受け付けないため代入時点でチェックするようになった。ナイスな修正です！

[Update missing actionpack CHANGELOG entry for wildcard route fix by ignacio-chiazzo · Pull Request #43461 · rails/rails](https://github.com/rails/rails/pull/43461)

OK: doc
ルーティングの設定で wildcard segments を指定できるんだ！？知らなかった。

### [週刊Railsウォッチ: ServerTimingミドルウェア追加、paramsで数値キーを許可、Railsで多要素認証ほか（20211011前編）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_10_11/112364)

> [link_toのリンク名をModel#to_sで推測する](https://techracho.bpsinc.jp/hachi8833/2021_10_11/112364#1-2)

[Let link_to infer link name from Model#to_s by olivierlacan · Pull Request #42234 · rails/rails](https://github.com/rails/rails/pull/42234)

これは便利そう。

> [数値のパラメータを許可できるようになった](https://techracho.bpsinc.jp/hachi8833/2021_10_11/112364#1-5) 

[Allow permitting numeric params by HParker · Pull Request #42501 · rails/rails](https://github.com/rails/rails/pull/42501)

```ruby
permit book: { authors_attributes: { '1': [ :name ], '0': [ :name, :age_of_death ] } }
```

↑のように書けるようになるので、いちおう仕様変更。でも既存のコードでこのような指定はしていないだろうから問題ないでしょう。

### [週刊Railsウォッチ: Ruby 3.1にYJITマージのプロポーザル、Rubyのmagic historyメソッド、JSのPartytownほか（20211012後編）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2021_10_12/112382)

Rails関係の記事はありませんでした。でも気になる記事が満載でした。特に、

> [SPAセキュリティ入門](https://techracho.bpsinc.jp/hachi8833/2021_10_12/112382#9-1)

は参考になりました。 [Basecamp](https://basecamp.com/) でフランクに localStorage を使っていたのでケースバイケースなんだろうなと感じていましたが、プレゼン資料には「(SPAにおいてセッションIDやトークンの格納場所は) Cookie と localStorageはどちらが安全とは言えず一長一短」とあるため、 localStorage という選択肢もあるのだとあらためて感じました。今後は localStorage を使わないと決めつけるのではなく、脅威が何かを考えて使えるときには使おうと思いました。

## 今回のおまけ

[パーフェクト Ruby on Rails　【増補改訂版】](https://amzn.to/3iU3sLW)を買いました。
<iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="//rcm-fe.amazon-adsystem.com/e/cm?lt1=_blank&bc1=000000&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=takaokouji-22&language=ja_JP&o=9&p=8&l=as4&m=amazon&f=ifr&ref=as_ss_li_til&asins=B08D3DW7LP&linkId=c0adfdc1bedc081139f69ee7713c17dc"></iframe>

網羅的に Ruby on Rails 6.0 のことが書かれていて、これ一冊でかなりいろいろなことが学べます。CarrierWave しか使ってなかったので ActiveStorage のことは全然知りませんでした。もっと早く買えばよかった。
