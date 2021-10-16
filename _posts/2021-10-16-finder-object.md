---
layout: single
title:  "詳解Railsデザインパターン：Finderオブジェクト"
categories: output
tags: ruby rails
toc: true
last_modified_at: 2021-10-16T12:12:54:54+0900
---
高尾が解説する 詳解Railsデザインパターン・シリーズの「Finderオブジェクト」編です。

他のデザインパターンも解説していますので、よろしければご覧ください。
- [詳解Railsデザインパターン：Formオブジェクト](/output/form-object/)
- [詳解Railsデザインパターン：Interactor](/output/interactor/)
- [詳解Railsデザインパターン：Queryオブジェクト](/output/query-object/)

- - -

Rails の Finderオブジェクト パターンはモデルで処理していたDBのSELECTを専用のクラスに追い出すことでモデルの肥大化を防ぐことに効果があるデザインパターンです。

関連するものとして [Queryオブジェクト](/output/query-object/) パターンがあります。Queryオブジェクト パターンはモデルの各 scope に 1 つのクラスが対応していて、シンプルな反面、大量にクラスができたり、コードが重複してしまったりといった問題があります。

それを解消するためのパターンがこの Finderオブジェクト です。

今回はこの Finderオブジェクト パターン を扱います。

{% include advertisements.html %}

## 関連記事・レポジトリ

まずは関連記事の紹介。これらを読めば Finderオブジェクト パターンを理解できます。

- [【Rails】Finder Object で検索ロジックをすっきりさせる - furaji \|> exists?](https://furaji.hatenablog.jp/entry/2020/05/09/043924)
  - この記事で Finderオブジェクト の存在を知りました。コントローラーからダイレクトに Finderオブジェクト を使えるようにしていて、たしかにこれならコードがすっきりします。
- [Digging Into the Finder Object Pattern - Words and Code](http://vaidehijoshi.github.io/blog/2015/10/27/digging-into-the-finder-object-pattern/)
  - 英語の記事。チュートリアル形式で Finderオブジェクト を理解できる
- [Finder Objects \| Janko's Blog](https://janko.io/finder-objects/)
  - 英語の記事。これもチュートリアル形式。ここで紹介されている Finderオブジェクト は method_missing を使ってモデルのメソッドを柔軟に扱えるようにしている。BaseFinderもいい感じ。とても参考になる。
- [Railsで導入してよかったデザインパターンと各クラスの役割について - masato_hiのブログ](https://masato-hi.hatenablog.jp/entry/2016/03/19/161712)
  - > Model(ActiveRecord)がDDDで言うRepositoryの機能を持っているため、classとして実装するのではなくconcerns moduleとして実装し、Modelでincludeしてしまうのが良いかなと思っています
  - なるほど、 concern は良さそう。
- [Code Show and Tell: PolymorphicFinder](https://thoughtbot.com/blog/code-show-and-tell-polymorphic-finder)
  - 英語の記事。Finderオブジェクト の builder のように振る舞う PolymorphicFinder。便利な時があるかもしれないけど、PolymorphicFinde の挙動がわかりにくく、コードが読みにくかったので私は使わないと思う。

## ApplicationFinderの実装例

これまでに紹介したパターンとは違い、Finderオブジェクト はブログ記事が少なく、決定的な実装例が見つけられませんでした。
共通するのは

- あるモデルに対する検索ページを想定して複雑な検索条件を引数で指定できる
- `SomeFinder.search` のようにクラスメソッドを提供する
- ↑のクラスメソッドは複数あるが `SomeFinder.published.search` のようにメソッドチェーンはできない

それを踏まえた Finderオブジェクト のベースクラスの実装例が以下です。ほぼ [Finder Objects | Janko's Blog](https://janko.io/finder-objects/) の BaseFinder です。

`app/finders/application_finder.rb`

```ruby
class ApplicationFinder
  class << self
    def model(klass = nil)
      @model = klass if klass
      @model
    end

    def method_missing(name, *args, **kwargs, &block)
      new(model.all).send(name, *args, **kwargs, &block)
    end
  end

  def initialize(scope)
    @scope = scope
  end

  private

  def scope(new_scope = nil)
    return @scope unless new_scope

    self.class.new(new_scope)
  end

  def arel_table
    self.class.model.arel_table
  end
end
```

使用例は以下です。これでコントローラーやモデルと独立して複雑な検索処理を MessageFinder に実装できます。

`app/finders/message_finder.rb`

```ruby
class MessageFinder < ApplicationFinder
  model Message

  def search(tenant:, user: nil, topic: nil, q: nil)
    messages = with_tenant(tenant)
    messages = scope(messages).with_user(user) if user
    messages = scope(messages).with_topic(topic) if topic
    messages = scope(messages).from_query(q) if q
    messages
  end

  def with_tenant(tenant)
    scope.where(tenant: tenant)
  end

  def with_user(user)
    scope.where(user: user)
  end

  def with_topic(topic)
    scope.where(topic: topic)
  end

  def from_query(q)
    scope.where(arel_table[:content].matches("%#{q}%"))
  end
end
```

## Finderオブジェクト vs Queryオブジェクト

さて、Finderオブジェクト と [Queryオブジェクト](/output/query-object/) を解説したところでひとつ疑問が湧きました。これらはどのように使い分ければいいのでしょうか？

これは私個人の考えなのですが

- Finderオブジェクト は検索ページのみ
- Queryオブジェクト は複雑な scope
- 簡単な scope はモデにル直接書く

というのはどうでしょうか。

Finderオブジェクトで定義した `with_tenant` や `with_user` は正直使いにくいです。メソッドチェーンができないため scope のほうが便利です。しかしながら、巨大な検索処理をモデルに書くのはメンテナンスがつらいので、Finderオブジェクト に書くといいのではないでしょうか。

また、複雑な scope も同様に Queryオブジェクト に書くと単体テストも書きやすいでしょう。 scope の共通化も実現できます。Queryオブジェクト で定義した scope を Finderオブジェクト で使うとより良いでしょう。

そして、基本的に Rails の仕組みにのっかったほうがメンテナンス性も学習コストも低いので簡単な scope はがんがんモデルに書きましょう。

## まとめ

- Finderオブジェクト パターンは検索ページのような複雑なDBのクエリを扱うときに有効です
- Finderオブジェクト、Queryオブジェクト、scopeの用途を決めておくといいでしょう
