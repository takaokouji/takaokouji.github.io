---
layout: single
title: "Turbo Rails Tutorial を Rails 7.2.1 / ruby 3.3.5 / Dev Container / tailwindcss でやってみた (2)"
categories: output
tags: ruby rails turbo devcontainer
toc: true
last_modified_at: 2024-09-09T12:00:00+0900
---

[前回の続き]({% post_url 2024-09-08-turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1 %}) です。[Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) と [tailwindcss](https://tailwindcss.com/) を利用して [Turbo Rails Tutorial](https://www.hotrails.dev/turbo-rails) をやっています。

前回までソースコードは [takaokouji/quote-editor:20a61f1](https://github.com/takaokouji/quote-editor/tree/20a61f17c9de40c180c97c53d5075249fa03db8f) にあります。

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- Visual Studio Code 1.93.0
  - Dev Container 機能拡張をインストール済み
- [Homebrew](https://brew.sh/ja/)
- ruby 3.3.5
  - [anyenv](https://github.com/anyenv/anyenv) で [rbenv](https://github.com/rbenv/rbenv) をインストール
  - ruby 3.3.5 を global に設定済み ( `rbenv global 3.3.5` )
- rails 7.2.1 gem
  - `gem install rails`
- mysql 9.0.1
  - `brew install mysql`
- zstd 1.5.6
  - `brew install zstd`
- mysql2 0.5.6 gem
  - `gem install mysql2`

### [A simple CRUD controller with Rails](https://www.hotrails.dev/turbo-rails/crud-controller-ruby-on-rails)

これは失敗だったのですが、作業を再開するにあたって Visual Studio Code のリモートエクスプローラーから quote-editor quote_editor-rails-app-1 を選択して、「現在のウィンドウのコンテナーで開く」ボタンを押す。
そして、ターミナルで `bin/dev` を実行してサーバーを起動して、ブラウザで `http://localhost:3000` にアクセス。

「さぁ、作業再開」と思ったのですが 「MySQL サーバーに接続できません」という旨のというエラーが発生しました。

作業再開の正しい手順は、コマンドパレットで「Dev Containers: Reopen in Container」を選択でした。すると、rails-appのコンテナだけでなく、mysql、redis、seleniumのコンテナも起動して、期待通りに動作するようになります。

気を取り直して続きをやります。

この章では、

- 自動テストの実装
- モデル/テーブルの作成
- コントローラーの作成
- ビューの作成

を行って、quote という1行メモの [CRUD](https://ja.wikipedia.org/wiki/CRUD) を作ります。

#### 自動テストの実装

```bash
bin/rails g system_test quotes
```

以下の警告が表示されました。

```text
/home/vscode/.rbenv/versions/3.3.5/lib/ruby/3.3.0/bundled_gems.rb:75: warning: /home/vscode/.rbenv/versions/3.3.5/lib/ruby/3.3.0/ostruct.rb was loaded from the standard library, but will no longer be part of the default gems starting from Ruby 3.5.0.
You can add ostruct to your Gemfile or gemspec to silence this warning.
Also please contact the author of jbuilder-2.12.0 to request adding ostruct into its gemspec.
```

Gemfileにostruct(OpenStruct)を追加して、この警告が出ないようにします。
参考情報: [Ruby 3.0 から OpenStruct が非推奨になった](https://zenn.dev/tyanakaz/articles/1d9a3f05165c31)

```ruby
gem "ostruct"
```

コピペで自動テスト `test/system/quotes_test.rb` を実装。

```ruby
require "application_system_test_case"

class QuotesTest < ApplicationSystemTestCase
  setup do
    @quote = quotes(:first) # Reference to the first fixture quote
  end

  test "Creating a new quote" do
    # When we visit the Quotes#index page
    # we expect to see a title with the text "Quotes"
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    # When we click on the link with the text "New quote"
    # we expect to land on a page with the title "New quote"
    click_on "New quote"
    assert_selector "h1", text: "New quote"

    # When we fill in the name input with "Capybara quote"
    # and we click on "Create Quote"
    fill_in "Name", with: "Capybara quote"
    click_on "Create quote"

    # We expect to be back on the page with the title "Quotes"
    # and to see our "Capybara quote" added to the list
    assert_selector "h1", text: "Quotes"
    assert_text "Capybara quote"
  end

  test "Showing a quote" do
    visit quotes_path
    click_link @quote.name

    assert_selector "h1", text: @quote.name
  end

  test "Updating a quote" do
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    click_on "Edit", match: :first
    assert_selector "h1", text: "Edit quote"

    fill_in "Name", with: "Updated quote"
    click_on "Update quote"

    assert_selector "h1", text: "Quotes"
    assert_text "Updated quote"
  end

  test "Destroying a quote" do
    visit quotes_path
    assert_text @quote.name

    click_on "Delete", match: :first
    assert_no_text @quote.name
  end
end
```

テストで使うデータベースの用意。

```bash
touch test/fixtures/quotes.yml
```

`test/fixtures/quotes.yml` もコピペ。

```yaml
first:
  name: First quote

second:
  name: Second quote

third:
  name: Third quote
```

テストに失敗することを確認。assetをビルドしてからテストを実行してくれるんですね。これは便利。

```text
$ bin/rails test:system
yarn install v1.22.22
[1/4] Resolving packages...
success Already up-to-date.
Done in 0.15s.
yarn run v1.22.22
$ esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets

  app/assets/builds/application.js      261.9kb
  app/assets/builds/application.js.map  481.9kb

Done in 0.13s.
yarn install v1.22.22
[1/4] Resolving packages...
success Already up-to-date.
Done in 0.07s.
yarn run v1.22.22
$ tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --minify

Rebuilding...

Done in 126ms.
Done in 0.54s.
Running 4 tests in a single process (parallelization threshold is 50)
Run options: --seed 10879

# Running:

E

Error:
QuotesTest#test_Creating_a_new_quote:
ActiveRecord::StatementInvalid: Mysql2::Error: Table 'quote_editor_test.quotes' doesn't exist
(省略)

Finished in 0.014672s, 272.6219 runs/s, 0.0000 assertions/s.
4 runs, 0 assertions, 0 failures, 4 errors, 0 skips
```

#### モデル/テーブルの作成

```bash
bin/rails generate model Quote name:string
```

`test/fixtures/quotes.yml` がコンフリクトするため、「n」を選択して、前の節で作成したものを採用。

モデル `app/models/quote.rb`。validates を追加。

```ruby
class Quote < ApplicationRecord
  validates :name, presence: true
end
```

テーブル `db/migrate/20240909124654_create_quotes.rb` (ファイル名のうち `20240909124654` は `bin/rails generate` を実行した日時を示す)。 `null: false` を追加。

```ruby
class CreateQuotes < ActiveRecord::Migration[7.2]
  def change
    create_table :quotes do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
```

DBのマイグレーション。

```bash
bin/rails db:migrate
```

#### コントローラーの作成

```bash
bin/rails generate controller Quotes
```

あら？コントローラーのgeneratorではルーティングが追加されないのですね。手作業で追加。

ルーティング `config/routes.rb` の修正。長かったのでコメントを削っています。

```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :quotes
end
```

コントローラー `app/controllers/quotes_controller.rb` の実装。

```ruby
class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]

  def index
    @quotes = Quote.all
  end

  def show
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)

    if @quote.save
      redirect_to quotes_path, notice: "Quote was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @quote.update(quote_params)
      redirect_to quotes_path, notice: "Quote was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_path, notice: "Quote was successfully destroyed."
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name)
  end
end
```

#### ビューの作成

一覧画面のビュー `app/controllers/app/views/quotes/index.html.erb` の作成。あとで tailwindcss に合わせて HTML の class を修正しますが、いまはコピペで進めます。

```erb
<main class="container">
  <div class="header">
    <h1>Quotes</h1>
    <%= link_to "New quote",
                new_quote_path,
                class: "btn btn--primary" %>
  </div>

  <%= render @quotes %>
</main>
```

詳細画面の一部のビュー `app/views/quotes/_quote.html.erb` の作成。

```erb
<div class="quote">
  <%= link_to quote.name, quote_path(quote) %>
  <div class="quote__actions">
    <%= button_to "Delete",
                  quote_path(quote),
                  method: :delete,
                  class: "btn btn--light" %>
    <%= link_to "Edit",
                edit_quote_path(quote),
                class: "btn btn--light" %>
  </div>
</div>
```

新規登録画面のビュー `app/views/quotes/new.html.erb` の実装。

```erb
<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>

  <div class="header">
    <h1>New quote</h1>
  </div>

  <%= render "form", quote: @quote %>
</main>
```

編集画面のビュー `app/views/quotes/edit.html.erb` の実装。

```erb
<main class="container">
  <%= link_to sanitize("&larr; Back to quote"), quote_path(@quote) %>

  <div class="header">
    <h1>Edit quote</h1>
  </div>

  <%= render "form", quote: @quote %>
</main>
```

新規作成画面と編集画面の共通ビュー `app/views/quotes/_form.html.erb` の実装。

```erb
<%= simple_form_for quote, html: { class: "quote form" } do |f| %>
  <% if quote.errors.any? %>
    <div class="error-message">
      <%= quote.errors.full_messages.to_sentence.capitalize %>
    </div>
  <% end %>

  <%= f.input :name, input_html: { autofocus: true } %>
  <%= f.submit class: "btn btn--secondary" %>
<% end %>
```

simple_form を使えるようにします。 `Gemfile` に以下を加えます。バージョンは現在(2024/09/09)の最新版にしています。

```ruby
gem "simple_form", "~> 5.3.1"
```

simple_formの設定の追加。

```bash
bundle install
bin/rails generate simple_form:install
```

simple_form の設定 `config/initializers/simple_form.rb は後回し。HTML 全体に tailwindcss を適用するときに合わせて設定します。

メッセージカタログ `config/locales/simple_form.en.yml` の修正。error_notification より下をコピペ。

```yaml
en:
  simple_form:
    "yes": 'Yes'
    "no": 'No'
    required:
      text: 'required'
      mark: '*'
      # You can uncomment the line below if you need to overwrite the whole required html.
      # When using html, text and mark won't be used.
      # html: '<abbr title="required">*</abbr>'
    error_notification:
      default_message: "Please review the problems below:"
    placeholders:
      quote:
        name: Name of your quote
    labels:
      quote:
        name: Name

  helpers:
    submit:
      quote:
        create: Create quote
        update: Update quote
```

詳細画面のビュー `app/views/quotes/show.html.erb` の実装。

```erb
<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>
  <div class="header">
    <h1>
      <%= @quote.name %>
    </h1>
  </div>
</main>
```

#### 動作確認

ここまでできたらテストを実行。

```text
$ bin/rails test:system
(省略)
.

Finished in 2.776025s, 1.4409 runs/s, 3.9625 assertions/s.
4 runs, 11 assertions, 0 failures, 0 errors, 0 skips
```

無事にパスした。しかしここでも警告が表示される。

```text
2024-09-09 13:27:53 WARN Selenium [:clear_local_storage] [DEPRECATION] clear_local_storage is deprecated and will be removed in a future release.
```

ここまでの修正をいったんコミットしてから対応する。

```bash
git add .
git commit -m 'feat: crud'
```

少し無理矢理感はあるが、 clear_local_storage と clear_session_storage を実行しないように設定して回避しました。

```diff
diff --git a/test/application_system_test_case.rb b/test/application_system_test_case.rb
index 8d40628..ebc486a 100644
--- a/test/application_system_test_case.rb
+++ b/test/application_system_test_case.rb
@@ -6,7 +6,9 @@ class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

     driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], options: {
       browser: :remote,
-      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
+      url: "http://#{ENV["SELENIUM_HOST"]}:4444",
+      clear_local_storage: false,
+      clear_session_storage: false
     }
   else
     driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
```

これで警告が消えて、見慣れたテスト結果になりました。

```text
$ bin/rails test:system
(省略)
# Running:

Capybara starting Puma...
* Version 6.4.2, codename: The Eagle of Durango
* Min threads: 0, max threads: 4
* Listening on http://172.19.0.5:45678
....

Finished in 1.405442s, 2.8461 runs/s, 7.8267 assertions/s.
4 runs, 11 assertions, 0 failures, 0 errors, 0 skips
```

最後にブラウザでも確認します。gemを追加したのでサーバーを再起動させます。control+Cで停止して `bin/dev` です。

無事に表示でき、一通りの操作ができました。が、スタイルシートがあたっていないため残念な見た目になっています。初見だとバグっているようにしか見えないかも。

![CRUD](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-2/SS_2024-09-09T22.47.30.png)

#### One more thing...

これで終わり。と思ったら続きがあった。

コントローラー `app/controllers/quotes_controller.rb` の修正。`render :new` と `render :edit`に `, status: :unprocessable_entity` を追加する。こうしないとバリデーションエラーの際に画面が再描画されません。Rails 7のルールです。

```ruby
  # (省略)

  def create
    @quote = Quote.new(quote_params)

    if @quote.save
      redirect_to quotes_path, notice: "Quote was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # (省略)

  def update
    if @quote.update(quote_params)
      redirect_to quotes_path, notice: "Quote was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # (省略)
```

DBの初期値 `db/seeds.rb` の実装。元々あったコメントはすべて削除した。

```ruby
puts "\n== Seeding the database with fixtures =="
system("bin/rails db:fixtures:load")
```

DBへの登録。

```bash
bin/rails db:seed
```

これで本当に終わり。お疲れ様でした。

今回はここまで。ソースコードは [takaokouji/quote-editor](https://github.com/takaokouji/quote-editor) においていますので、興味がある方は Watch していただけると励みになります。

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
