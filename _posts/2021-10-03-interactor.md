---
layout: single
title:  "詳解Railsデザインパターン：Interactor"
categories: output
tags: ruby rails
toc: true
last_modified_at: 2021-10-03T23:23:27:13+0900
---
高尾が解説する 詳解Railsデザインパターン・シリーズの「Interactor」編です。

他のデザインパターンも解説していますので、よろしければご覧ください。
- [詳解Railsデザインパターン：Formオブジェクト](/output/form-object/)

- - -

Rails の Interactor パターンは [Formオブジェクト](/output/form-object/) と同様に Rails のコントローラーの肥大化するのを防ぐことに効果があるデザインパターンです。

類似するRailsのデザインパターンとして「Service Object」と呼ばれるものがあります。これについては [Railsで重要なパターンpart 1: Service Object（翻訳）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2017_10_16/46482) が詳しいです。さらに [Service Objectがアンチパターンである理由とよりよい代替手段（翻訳）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2018_04_16/55130) には問題点として以下が挙げられています。

> 本質的にService Objectパターンそのものには、コードベースを読みやすくする力も、メンテしやすくする能力も、concernをうまく分割する手腕もありはしない

本質的に Interactor パターンは Service Object パターンと同じなのですが、いくつかの制限があります。それによって、 Service Object の問題点が解消されています。

今回はこの Interactor パターンを扱います。

{% include advertisements.html %}

## 関連記事・レポジトリ

まずは関連記事の紹介。どれも良記事。これらを読めば Interactor を理解できます。
- [Railsのデザインパターン: Interactorオブジェクト - applis](https://applis.io/posts/rails-design-pattern-interactor-objects)
  - 日本語だとこれでOK
- [collectiveidea/interactor: Interactor provides a common interface for performing complex user interactions.](https://github.com/collectiveidea/interactor)
  - Interactor パターンを Ruby で使うための interactor gem。英語だけで README.md を読めば Interactor パターンのことを理解できる
- [interactor gem についてまとめてみた (1/2) - Qiita](https://qiita.com/verdy89/items/00a2992a9a62cacec00e)
  - ↑の解説記事
- [dev.toのServiceクラスについてDDDとPofEAAを読んで考察してみた](https://zenn.dev/kitabatake/articles/devto-service)
  - これは Service Object パターンの解説ですが、 Interactor パターンにも通じるところがあり、とても勉強になりました。余談ですが、 [DDD](https://amzn.to/39ZfPBs) を通しで読むのは難しく、何度も挫折しているのですが、目的をもって特定の箇所だけを読むのであれば楽しく読めますね。

次は Interactor パターンのコード例ですが、 [collectiveidea/interactor の Interactors in the Controller](https://github.com/collectiveidea/interactor#interactors-in-the-controller) にあります。

他にも [collectiveidea/interactor の Clarity](https://github.com/collectiveidea/interactor#clarity) には Interactor の命名についてのヒントがあります。
> TIP: Name your interactors after your business logic, not your implementation. CancelAccount will serve you better than DestroyUser as the account cancellation interaction takes on more responsibility in the future.
> (翻訳: DeepL)
> ヒント: インタラクタの名前は、実装ではなくビジネスロジックに基づいて命名してください。CancelAccountは、DestroyUserよりも、将来的にアカウント・キャンセルのインタラクションがより責任を負うようになったときに役立つでしょう。

## Service Object vs Interactor

私は Service Object パターンの3つの問題を Interactor では以下のようにして解決していると考えています。

- 問題1: コードベースを読みやすくする力がない
  - → コントローラーのコードのみ Interactor に移動させ、名前もドメインにあったものにする (例: DestroyUser ではなく CancelAccount)。モデルのコードはそのまま。
- 問題2: メンテしやすくする能力がない
  - → インターフェースは `call` ただ 1 つ。引数と結果は `context` に格納。
- 問題3: concernをうまく分割する手腕がない
  - → 複数の Interactor を束ねる Organizer を提供。例えば、共通の処理としてメール通知 Interactor を用意して、複数の Organizer から利用できる。

## Interactorの実装

[interactor gem](https://github.com/collectiveidea/interactor) と [interactor-rails gem](https://github.com/collectiveidea/interactor-rails) を使えばアプリケーションに Interactor パターンを導入できます。説明も上記の関連記事・レポジトリで十分ですね。それくらい、 Interactor パターンはよく使われているのでしょうね。

とはいえ、それだけではなんなので、 [interactor gem](https://github.com/collectiveidea/interactor) を参考にして実装した Interactor モジュールを以下に挙げます。hook、rollback、Organizerは省略しています。とてもシンプルです。

```ruby
require "ostruct"

module Interactor
  class Failure < StandardError
    attr_reader :context

    def initialize(context)
      @context = context
      super
    end
  end

  class Context < OpenStruct
    class << self
      def build(context = {})
        self === context ? context : new(context)
      end
    end

    def fail!
      @failure = true
      raise Failure, self
    end

    def success?
      !failure?
    end

    def failure?
      @failure || false
    end
  end

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      attr_reader :context
    end
  end

  module ClassMethods
    def call(context = {})
      new(context).tap(&:run).context
    end
  end

  def initialize(context = {})
    @context = Context.build(context)
  end

  def run
    call
  rescue Failure
  end

  def call
  end
end
```

今回、 [interactor gem](https://github.com/collectiveidea/interactor) と [interactor-rails gem](https://github.com/collectiveidea/interactor-rails) のコードを一通り読んだのですが、コード量も少なく、Railsの特定のバージョンに依存したコードもありません。Rails 自体をバージョンアップしても問題はなさそうです。万が一、問題があったとしてもモンキーパッチで回避できたり、PRを送ればすぐに修正してくれそうです。

## まとめ

Interactor パターンを利用することでコントローラーのコードの一部を Interactor に移動させることができます。

Service Object パターンと違って以下の制限があります (interactor gemを使う場合)。
- インターフェースは `call` ただ 1 つ
- 引数、結果は context に格納
- コントローラーの処理のみ Interactor に移動させ、モデルの処理はモデルのまま (これは制限というよりも、慣習とか規約ですね)

[interactor gem](https://github.com/collectiveidea/interactor) と [interactor-rails gem](https://github.com/collectiveidea/interactor-rails) を利用すれば簡単に Interactor を導入できます。Railsバージョンアップの際も問題ないでしょう。
