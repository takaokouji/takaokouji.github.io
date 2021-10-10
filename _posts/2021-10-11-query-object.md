---
layout: single
title:  "詳解Railsデザインパターン：Queryオブジェクト"
categories: output
tags: ruby rails
toc: true
last_modified_at: 2021-10-11T00:00:04:00+0900
---
高尾が解説する 詳解Railsデザインパターン・シリーズの「Queryオブジェクト」編です。

他のデザインパターンも解説していますので、よろしければご覧ください。
- [詳解Railsデザインパターン：Formオブジェクト](/output/form-object/)
- [詳解Railsデザインパターン：Interactor](/output/interactor/)

- - -

Rails の Queryオブジェクト パターンは scope を別ファイルに定義することでモデルの肥大化を防ぐことに効果があるデザインパターンです。

今回はこの Queryオブジェクト パターン を扱います。

{% include advertisements.html %}

## 関連記事・レポジトリ

まずは関連記事の紹介。これらを読めば Queryオブジェクト パターンを理解できます。
- [Railsで重要なパターンpart 2: Query Object（翻訳）｜TechRacho by BPS株式会社](https://techracho.bpsinc.jp/hachi8833/2017_10_25/47287)
  - 具体的なコード例はありませんが、Query Objectをどんなときに使うかや注意点がわかります。
- [Railsのデザインパターン: Queryオブジェクト - applis](https://applis.io/posts/rails-design-pattern-query-objects)
  - 具体的なコード例があります。↑とこれを読めば、Queryオブジェクト パターンはバッチリです。
- [Rails - ActiveRecord の scope を Query object で実装する - Qiita](https://qiita.com/furaji/items/12cef3ec4d092865af88)
  - [Delegating to Query Objects through ActiveRecord scopes](https://craftingruby.com/posts/2015/06/29/query-objects-through-scopes.html) の翻訳
  - 複雑な scope を Query オブジェクトに追い出す方法。Query オブジェクトにいくつかのメソッドを定義することで実現している。

解説付きの実装例は [pattern/query.rb at master · Selleo/pattern](https://github.com/Selleo/pattern/blob/master/lib/patterns/query.rb) があります。このレポジトリにあるコードはシンプルでいいですね。

なお、前述した [Rails - ActiveRecord の scope を Query object で実装する - Qiita](https://qiita.com/furaji/items/12cef3ec4d092865af88) の後続記事として [【Rails】Finder Object で検索ロジックをすっきりさせる - furaji \|> exists?](https://furaji.hatenablog.jp/entry/2020/05/09/043924) があります。 **scope に対する Query オブジェクトは使わなくなり、最近は Finder オブジェクトを使っている** とのこと。 (次は Finder オブジェクトを解説したいな)

## Selleo/pattern を使って Query オブジェクトを定義

[pattern/query.rb at master · Selleo/pattern](https://github.com/Selleo/pattern/blob/master/lib/patterns/query.rb) を利用し、[解説](https://github.com/Selleo/pattern#query) に従って queries に対象のモデルまたはリレーション、プライベートメソッドとして query を定義すればOKです。このクラスは `app/queries/recently_activated_users_query.rb` に配置します。とても簡単ですね。

```ruby
class RecentlyActivatedUsersQuery < Patterns::Query
  queries User

  private

  def query
    relation.active.where(activated_at: date_range)
  end

  def date_range
    options.fetch(:date_range, default_date_range)
  end

  def default_date_range
    Date.yesterday.beginning_of_day..Date.today.end_of_day
  end
end
```

[使い方](https://github.com/Selleo/pattern#usage) も簡単です。scope での使い方も解説されていてありがたいです。

```ruby
RecentlyActivatedUsersQuery.call
RecentlyActivatedUsersQuery.call(User.without_test_users)
RecentlyActivatedUsersQuery.call(date_range: Date.today.beginning_of_day..Date.today.end_of_day)
RecentlyActivatedUsersQuery.call(User.without_test_users, date_range: Date.today.beginning_of_day..Date.today.end_of_day)

class User < ApplicationRecord
  scope :recently_activated, RecentlyActivatedUsersQuery
end
```

## Query オブジェクトのベースクラスの実装

せっかくなので、 [pattern/query.rb at master · Selleo/pattern](https://github.com/Selleo/pattern/blob/master/lib/patterns/query.rb) を参考にして自作します。

というのも、私は最近「Rails のアプリケーションをメンテナンスし続けるには、利用する gem を最小限にして、できれば Rails のみで完結したい」と考えるようになり、 Selleo/pattern のようなシンプルなものは gem ではなく、最小限の実装をアプリケーションに取り込んだほうが良い、と考えているからです。

gem のアップデートはそれなりにコストがかかるんですよね。たびたびメンテナンスされなくなったり、Railsのバージョンアップで対応できなくなったり。オープンソースソフトウェアなので困ったら自分で直せばいいのですが、いつまでもそのアプリケーションの開発に携われるわけでもなかったりしてね。

というわけで、以下が最小限の実装です。クラス名は ApplicationController や ApplicationRecord に従って ApplicationQuery にしました。とてもシンプルですね。これだけで [pattern/query.rb at master · Selleo/pattern](https://github.com/Selleo/pattern/blob/master/lib/patterns/query.rb) を実現できます。

`app/queries/application_query.rb`

```ruby
require "active_record"

# The Query object pattern base class
#
# based on https://github.com/Selleo/pattern/blob/master/lib/patterns/query.rb
# MIT License: https://github.com/Selleo/pattern/blob/master/LICENSE.txt
class ApplicationQuery
  class << self
    attr_accessor :base_relation

    def queries(subject)
      self.base_relation = subject
    end
    
    def call(*args)
      new(*args).send(:query)
    end
  end

  def initialize(*args)
    @options = args.extract_options!
    @relation = args.first || base_relation
  end

  private

  attr_reader :relation, :options

  def base_relation
    return self.class.base_relation if self.class.base_relation.is_a?(ActiveRecord::Relation)

    self.class.base_relation.all
  end
  
  # :nocov:
  def query
    raise NotImplementedError, "You need to implement #query method which returns ActiveRecord::Relation object"
  end
  # :nocov:
end
```

## まとめ

- Queryオブジェクト パターンは scope を別ファイルに定義することでモデルの肥大化を防ぐことに効果があるデザインパターン
- [pattern/query.rb at master · Selleo/pattern](https://github.com/Selleo/pattern/blob/master/lib/patterns/query.rb) を使えばOK
- Queryオブジェクトのベースクラスは簡単に自作できる
