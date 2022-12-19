---
layout: single
title:  "「逆引きCapybara大辞典」補完計画:001 POSTリクエストする"
categories: output
tags: ruby rails capybara
toc: false
last_modified_at: 2022-12-18T00:00:06:21+0900
---
1日に1回はアクセスしているんじゃないかってくらい [使えるRSpec入門・その4「どんなブラウザ操作も自由自在！逆引きCapybara大辞典」](https://qiita.com/jnchito/items/607f956263c38a5fec24) には大変お世話になっています。これはすごいドキュメントです。永久保存版です。本当に感謝です。

このドキュメントには、 Rails でシステムテスト(feature spec)を書くときに「あれ？こんなことがしたいけど、どうすればいいんだっけ？？？」というときの答えが書いてあります。60個以上あります。すごいです。ほとんどのことがこのドキュメントを読めばわかります。

ただ、それでもわかんないことがあるんですよね。システムテストって、だいたい複雑でシステムによってやりたいことが違うんですよね。だから、60個じゃあ、まだまだ足りません。

ということで、私がシステムテストを実装するときに見つけた問題とその回答をこのブログに随時挙げていこうと思います。「逆引きCapybara大辞典」を勝手に補完して、より良いものにしていこう、というシリーズものです。

今回はその1回目ってことで、システムテストからPOSTする方法について書きます。

{% include advertisements.html %}

## 「[逆引きCapybara大辞典](https://qiita.com/jnchito/items/607f956263c38a5fec24)」補完計画:001 POSTリクエストする

visitメソッドであるURLにアクセスすることができます。
```ruby
visit new_content_path
```
このときの HTTP メソッドはGETです。RailsのControllerのアクションだと `index`, `new`, `show` ですね。

では、Railsの`create`にあたる POST はどうすればいいのでしょうか？

```ruby
visit contents_path, method: :post # ！？ こんなことはできません！
```

残念ながら Capybara には、POST するためのメソッドは用意されていません。
そのため、 POST する場合は Net::HTTP を使います。ただし、適切な current_url が設定されていることを前提としていますので、事前に `visit root_path` などでウェブページを表示しておく必要があります。

```ruby
uri = URI.parse(current_url)
uri.path = contents_path
res = Net::HTTP.post_form(uri, param1: 'param1の値', param2: 'param2の値')
expect(res).to be_a(Net::HTTPSuccess)
```

メソッドにしてもいいでしょう。

```ruby
def post(path, **params)
  uri = URI.parse(current_url)
  uri.path = path
  res = Net::HTTP.post_form(uri, **params)
  expect(res).to be_a(Net::HTTPSuccess)
end
```

これは以下のように使います。

```ruby
post cotents_path, param1: 'param1の値', param2: 'param2の値'
```
