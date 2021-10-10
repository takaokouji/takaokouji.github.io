---
layout: single
title:  "詳解Railsデザインパターン：Formオブジェクト"
categories: output
tags: ruby rails
toc: true
last_modified_at: 2021-10-10T22:22:14:03+0900
---
高尾が解説する 詳解Railsデザインパターン・シリーズ[^1] の「Formオブジェクト」編です。
(2021-10-10T22:22:14:34+0900追記) パターン名を「FormObject」から「Formオブジェクト」に変更しました。

[^1]: 詳解Railsデザインパターン・シリーズといいつつ、まだこの記事しかありません。続けばいいな〜。

- - -

Railsのコントローラーが肥大化するのは避けられません。ユーザーからのリクエストのチェック、検索、フォームの生成、レコードの永続化。そもそもやることが多い。

1つのフォームで複数のレコード、複数のモデルを扱うようになると `accepts_nested_attributes_for` を使うことになります。が、このメソッド、評判がよくありません。
[Railsのaccepts_nested_attributes_forについて解説してみた。 | 目指せ、スーパーエンジニア](https://hirocorpblog.com/post-213/) より
> accepts_nested_attributes_forメソッドがあまりに初心者殺しというか、製作者のDHHさんにこのメソッドを
> 抹殺したい・・・
> と言わせるくらいの極悪メソッドであるのですが、現在はこのメソッドを使わざるを得ない状況なので初学者の方を救うべく記事をまとめます。

[accepts_nested_attributes_forを使わず、複数の子レコードを保存する | Money Forward Engineers' Blog](https://moneyforward.com/engineers_blog/2018/12/15/formobject/) より
> 社内でも accepts_nested_attributes_for は今後は使わないようにして、既存のコードもリプレイスしていく活動が始まっているので accepts_nested_attributes_for を使わずに、 FormObject を使って複数リリースの同時保存を行うコードを書いてみました。

↑で紹介されている方法はよく使われているため Formオブジェクト パターンという名前がついています。

今回はこの `Formオブジェクト` パターンを扱います。

{% include advertisements.html %}

## 関連記事・レポジトリ

まずは関連記事の紹介。どれも良記事。これらを読めば Formオブジェクト を理解した気になれます。
- [Railsのデザインパターン: Formオブジェクト - applis](https://applis.io/posts/rails-design-pattern-form-objects)
  - 日本語だとこれでOK
- [Let's play design patterns: Form Objects – Nimble](https://nimblehq.co/blog/lets-play-design-patterns-form-objects)
  - 英語だとこれでOK
- [Disciplined Rails: Form Object Techniques & Patterns — Part 1 by Jaryl Sim - Medium](https://jaryl.medium.com/disciplined-rails-form-object-techniques-patterns-part-1-23cfffcaf429)
  - パート3まであって網羅されている
  - これを読み切れば間違いない
- [FormObjectにおける`#to_model`について｜TechRacho（テックラッチョ）〜エンジニアの「？」を「！」に〜｜BPS株式会社](https://techracho.bpsinc.jp/gengen/2021_08_24/110885)
  - タイムリーなネタ。この考えに同意し、この記事でも `to_model` メソッドは実装しません。

次に、Railsデザインパターンのコード例が [Selleo/pattern: A collection of lightweight, standardized, rails-oriented patterns.](https://github.com/Selleo/pattern) で公開されています。
Formオブジェクト の実装例は [pattern/form.rb at master · Selleo/pattern](https://github.com/Selleo/pattern/blob/master/lib/patterns/form.rb) です。

このコード例がとても良い。説明付きでコードが短く、gemを使わなくても再実装が簡単。Railsデザインパターンで困ったらまずはこのコードを見ればOK。

## 対象のRubyとRails

ここからは、具体的なコード例を挙げていきます。ただし、Formオブジェクト が最も使われている検索フォームのようなものは扱わず、特定のモデルの CRUD のフォームを扱います。

対象のRubyとRailsは以下です。
- ruby 3.0.1p64 (2021-04-05 revision 0fb782ee38) [x86_64-darwin19]
- Rails 6.1.4.1

## ベースクラス FormBase

まずは Formオブジェクト の親クラスとなる FormBase クラス。

```ruby
# app/forms/form_base.rb
class FormBase
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  def initialize(attributes: nil)
    attributes ||= default_attributes
    super(attributes)
  end

  def id
    nil
  end

  def persisted?
    false
  end

  def save
    valid? ? persist : false
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error([e.message, *e.backtrace].join($/))
    errors.add(:base, e.message)

    false
  end

  private

  def default_attributes
    {}
  end

  def persist
    true
  end
end
```

## 単純なモデルに対する Formオブジェクト

更新対象の属性が name だけという単純なモデルに対する Formオブジェクト 。 **こういうものには Formオブジェクト パターンを使うべきではないのですが** 、これから複雑なものを説明するのでそのための準備運動です。

いちおうマルチテナントを意識して tenant との関連も扱います。バリデーションはモデルのものをそのまま使う想定です。 Formオブジェクト とモデルで2重管理するのはつらいですからね。

### Formオブジェクト

操作対象のモデルのインスタンスを @user に格納します。
id と persisted? は @user のものをそのまま使います。
initialize では必須のパラメーターとしてテナント情報(tenant)、省略可能なパラメーターとしてリクエストパラメーター(attribute)、更新対象のモデルのインスタンス(user)を取り、それらをインスタンス変数に格納します。userが省略された場合に初期状態の User モデルのインスタンスを生成するのがポイントです。
フォームからの入力は `user_attributes=(other)` で処理します。

また、モデルのバリデーションはそのまま使っていて、persist のなかで user.invalid? でチェック。バリデーションエラーが発生したら `errors_from_user` を呼び出して **Formオブジェクト の errors に User モデルのバリデーションエラーのメッセージをコピーしています** 。

```ruby
# app/forms/user_form.rb
class UserForm < FormBase
  attr_accessor :user

  delegate :id, :persisted?, to: :user

  def initialize(tenant:, attributes: nil, user: nil)
    @tenant = tenant
    @user = user || User.new(tenant: tenant)
    super(attributes: attributes)
  end

  def user_attributes=(other)
    user.attributes = other
  end

  private

  attr_reader :tenant

  def default_attributes
    {
      user: user,
    }
  end

  def persist
    raise ActiveRecord::RecordInvalid if user.invalid?

    ActiveRecord::Base.transaction do
      user.save!
    end

    true
  rescue ActiveRecord::RecordInvalid
    errors_from_user

    false
  end

  def errors_from_user
    user.errors.each do |error|
      errors.add(:base, error.full_message)
    end
  end
end
```

### Controller

コントローラーでは User モデルから UserForm を使うように変更しています。
あとリクエストパラメーターは `form_params` メソッドで処理するようにしています。

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # (省略) before_action :set_tenant, before_action :set_user, index, show

  def new
    @form = UserForm.new(tenant: @tenant)
  end

  def edit
    @form = UserForm.new(tenant: @tenant, user: @user)
  end

  def create
    @form = UserForm.new(tenant: @tenant, attributes: form_params)

    if @form.save
      redirect_to user_path(@form), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @form = UserForm.new(tenant: @tenant, attributes: form_params, user: @user)
    if @form.save
      redirect_to user_path(@form), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # (省略) destroy

  private

  # (省略) set_tenant, set_user

  def form_params
    params.require(:user_form).permit(user_attributes: [:name])
  end
end
```

### View

まずは `app/views/users/_form.html.erb` 。 `form_with` が変わり、 `form.fields_for(:user_attributes, user_form.user)` を追加しています。

```erb
<%# app/views/users/_form.html.erb %>
<% user_form # @param [UserForm] user_form %>
<%= form_with(model: user_form, url: user_form.persisted? ? user_path(user_form) : users_path) do |form| %>
  <% if user_form.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(user_form.errors.count, "error") %> prohibited this user from being saved:</h2>

      <ul>
        <% user_form.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <%= form.fields_for(:user_attributes, user_form.user) do |user_fields| %>
    <div class="field">
      <%= user_fields.label :name %>
      <%= user_fields.text_field :name %>
    </div>
  <% end %>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

次に `app/views/users/new.html.erb` と `app/views/users/edit.html.erb` です。 `render 'form', user_form: @form` がポイントです。

```erb
<%# app/views/users/new.html.erb %>
<h1>New User</h1>

<%= render 'form', user_form: @form %>

<%= link_to 'Back', users_path %>
```

```erb
<%# app/views/users/edit.html.erb %>
<h1>Editing User</h1>

<%= render 'form', user_form: @form %>

<%= link_to 'Show', @user %> |
<%= link_to 'Back', users_path %>
```

### その他

さらに、 `config/locales/en.yml` に以下の `activemodel.models.user_form` と `activemodel.attributes.user_form` を追加。これで `form.submit` のラベルが適切なものになります。

```yml
en:
  activemodel:
    models:
      user_form: User
    attributes:
      user_form:
        name: "Name"
```

## 1対多のモデルに対する Formオブジェクト

続いては、1つの目標 Objective と3つの成果指標 KeyResult を扱う場合。
Formオブジェクト を使えば `accepts_nested_attributes_for` は不要になります。が、その分やることは多いです。

### Formオブジェクト

Objective モデルを objective、KeyResult モデルを key_results で扱います。前者は単体、後者は複数。
UserForm と違うところは `initialize`、`key_results_attributes=`、`errors_from_key_results` で複数のレコードを扱うところです。
このような実装方法であれば扱うモデルが増えても、また、それが単体でも複数でも同じように実装できます。

また、 `validates :key_results, length: { is: NUM_KEY_RESULTS }` のように、このフォームでは3つ成果指標を扱うといったモデルの制約ではなくフォームのものはここに記述します。

```ruby
# app/forms/okr_form.rb
class OkrForm < FormBase
  NUM_KEY_RESULTS = 3

  attr_accessor :objective
  attr_accessor :key_results

  delegate :id, :persisted?, to: :objective

  validates :key_results, length: { is: NUM_KEY_RESULTS }
  
  def initialize(tenant:, attributes: nil, okr: nil)
    @tenant = tenant
    @objective = okr || Objective.new(tenant: @tenant)
    @key_results = okr&.key_results || NUM_KEY_RESULTS.times.map { |i|
      KeyResult.new(tenant: @tenant, objective: @objective, position: i + 1)
    }
    super(attributes: attributes)
  end

  def objective_attributes=(other)
    objective.attributes = other
  end

  def key_results_attributes=(others)
    @key_results = others.values.map { |other|
      kr = key_results.find { |x|
        x.position.to_s == other[:position]
      } || KeyResult.new(tenant: @tenant, objective: objective)
      kr.attributes = other
      kr
    }
  end

  private

  attr_reader :tenant

  def default_attributes
    {
      objective: objective,
      key_results: key_results,
    }
  end

  def persist
    raise ActiveRecord::RecordInvalid if [objective, *key_results].select(&:invalid?).present?

    ActiveRecord::Base.transaction do
      objective.save!
      key_results.each(&:save!)
    end

    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    errors_from_objective
    errors_from_key_results

    false
  end

  def errors_from_objective
    objective.errors.each do |error|
      errors.add(:base, error.full_message)
    end
  end

  def errors_from_key_results
    key_results.each do |kr|
      attribute = "#{KeyResult.model_name.human}#{kr.position}"
      kr.errors.each do |error|
        message = (error.attribute == :content ? error.message : error.full_message)
        errors.add(
          :base,
          I18n.t(:"errors.format", default: "%{attribute} %{message}", attribute: attribute, message: message)
        )
      end
    end
  end
end
```

### Controller

コントローラーは User のものからほとんど変わりません。これが Formオブジェクト のメリットです。逆にいうとそれくらいしかメリットはないかもしれません。

```ruby
# app/controllers/okrs_controller.rb
class OkrsController < ApplicationController
  # (省略) before_action :set_tenant, before_action :set_user, index, show

  def new
    @form = OkrForm.new(tenant: @tenant)
  end

  def edit
    @form = OkrForm.new(tenant: @tenant, okr: @okr)
  end

  def create
    @form = OkrForm.new(tenant: @tenant, attributes: form_params)

    if @form.save
      redirect_to okr_path(@form), notice: "Okr was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @form = OkrForm.new(tenant: @tenant, attributes: form_params, okr: @okr)

    if @form.save
      redirect_to okr_path(@form), notice: "Okr was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # (省略) destroy

  private

  # (省略) set_okr
  
  def form_params
    params.require(:okr_form).permit(objective_attributes: %i[content end_at],
                                     key_results_attributes: %i[position content])
  end
end
```

### View

`app/views/okrs/_form.html.erb` は `UserForm` と同様ですね。
関連するレコードが2つになったので `form.fields_for` を 2 回呼び出しています。

```erb
<%# app/views/okrs/_form.html.erb %>
<% okr_form # @param [OkrForm] ork_form %>
<%= form_with(model: okr_form, url: okr_form.persisted? ? okr_path(okr_form) : okrs_path) do |form| %>
  <% if okr_form.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(okr_form.errors.count, "error") %> prohibited this okr from being saved:</h2>

      <ul>
        <% okr_form.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <%= form.fields_for(:objective_attributes, okr_form.objective) do |o_fields| %>
    <div class="field">
      <%= o_fields.label :content %>
      <%= o_fields.text_area :content %>
    </div>

    <div class="field">
        <%= o_fields.label :end_at %>
        <%= o_fields.date_field :end_at %>
    </div>
  <% end  %>

  <% okr_form.key_results.each do |kr| %>
    <%= form.fields_for(:key_results_attributes, kr, index: kr.position) do |kr_fields| %>
      <div class="field">
        <%= kr_fields.label :content, "#{KeyResult.human_attribute_name(:content)}#{kr.position}" %>
        <%= kr_fields.hidden_field :position %>
        <%= kr_fields.text_area :content %>
      </div>
    <% end %>
  <% end %>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

### その他

`config/locales/en.yml` の関連箇所だけを抜粋します。

```yml
en:
  activemodel:
    models:
      okr_form: OKR
    attributes:
      okr_form:
        objective: Objective
        key_results: KR
```

## まとめ

Formオブジェクト パターンを利用することでコントローラーのコードの一部を Formオブジェクト に移動させることができます。
また、複数のモデルやそのインスタンスの関係をチェックするようなバリデーションをモデルから Formオブジェクト に移動させることができます。

その反面、単体のモデルのインスタンスを扱うフォームでは、Formオブジェクト に関するコードを追加するオーバーヘッドが大きくなります。

適材適所で使う必要があるでしょう。
