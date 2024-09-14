---
layout: single
title: "Turbo Rails Tutorial を Rails 7.2.1 / ruby 3.3.5 / Dev Container / tailwindcss でやってみた (5)"
categories: output
tags: ruby rails turbo devcontainer
toc: true
last_modified_at: 2024-09-14T20:00:00+0900
---

[前回の続き]({% post_url 2024-09-14-turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-4 %}) です。[Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) と [tailwindcss](https://tailwindcss.com/) を利用して [Turbo Rails Tutorial](https://www.hotrails.dev/turbo-rails) をやっています。

今回は Turbo Drive と Turbo Frame/Stream です。

前回までソースコードは [takaokouji/quote-editor:94fb9f7](https://github.com/takaokouji/quote-editor/tree/94fb9f70c651beec05159aee60a46018194ff919) にあります。

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- [Homebrew](https://brew.sh/ja/)
- Visual Studio Code 1.93.0
  - Dev Container 機能拡張をインストール済み
- ruby 3.3.5
  - [anyenv](https://github.com/anyenv/anyenv) で [rbenv](https://github.com/rbenv/rbenv) をインストール
  - ruby 3.3.5 を global に設定済み ( `rbenv global 3.3.5` )
- rails 7.2.1 gem
  - `gem install rails`
- 他のソフトウェアは Docker コンテナ上にインストール

### [Turbo Drive](https://www.hotrails.dev/turbo-rails/turbo-drive)

Turbo Drive は gem を導入するだけでユーザー体験が格段にアップする仕組みです。が、実際には、導入したけどフォームが動かない / 動かなくなった、ってことでオフにされがちです。一昔前の [turbolinks](https://github.com/turbolinks/turbolinks) と同じような扱い。

でも、この章を理解することでかなりの疑問が解消され、導入するための勇気がもらえます。

rails 7.2.1 では最初から Turbo Drive が有効になっているので、コードの修正は２点だけ。画面読み込みの進捗バーの色を変えています。

`app/assets/stylesheets/components/turbo_progress_bar.css`

```css
@layer components {
  .turbo-progress-bar {
    @apply bg-gradient-to-tr from-primary to-primary-rotate;
  }
}
```

`app/assets/stylesheets/application.postcss.css` に以下を追加。

```css
@import "./components/turbo_progress_bar.css";
```

こんな感じで進捗バーがテーマカラーの赤色になります。

![赤色の進捗バー](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T13.11.22.png)

### [Turbo Frames and Turbo Stream templates](https://www.hotrails.dev/turbo-rails/turbo-frames-and-turbo-streams)

ここからがチュートリアルの本題です。

オーソドックスは CRUD ウェブアプリを JavaScript を書かずに [SPA](https://www.perplexity.ai/search/webkai-fa-niokeruspatohahe-tes-GtSdbtfWTLuRPbojCgKeGA#0) っぽくしていきます。

まずはテストの修正から。このチュートリアルはテストファーストなんですよね。すごく好きです。

差分がわかりにくくなるため、いったんコメントを削除してから変更します。新規登録と更新のテストを変えています。

```ruby
  test "Creating a new quote" do
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    click_on "New quote"
    # (削除) assert_selector "h1", text: "New quote"
    # 新規作成画面に遷移せず、一覧画面に新規作成のためのフォームを表示する
    fill_in "Name", with: "Capybara quote"

    # (追加) 一覧画面のままであることを確認
    assert_selector "h1", text: "Quotes"
    click_on "Create quote"

    assert_selector "h1", text: "Quotes"
    assert_text "Capybara quote"
  end

  test "Updating a quote" do
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    click_on "Edit", match: :first
    # (削除) assert_selector "h1", text: "Edit quote"
    # 同様に、編集画面に遷移せず、一覧画面に編集のためのフォームを表示する
    fill_in "Name", with: "Updated quote"

    assert_selector "h1", text: "Quotes"
    click_on "Update quote"

    assert_selector "h1", text: "Quotes"
    assert_text "Updated quote"
  end
```

テストに失敗するので、これからアプリケーションを修正していきます。

```text
vscode ➜ /workspaces/quote-editor (main) $ bin/rails test test/system/quotes_test.rb
(省略)
Finished in 8.909481s, 0.4490 runs/s, 0.7857 assertions/s.
4 runs, 7 assertions, 2 failures, 0 errors, 0 skips
```

#### 詳細表示と削除

まずは一覧の Quote の Turbo Frame/Stream 対応。

`app/views/quotes/_quote.html.erb`

```erb
<%# locals: (quote:) %>
<%= turbo_frame_tag quote do %>
  <div class="quote">
    <%= link_to quote.name, quote_path(quote), data: { turbo_frame: "_top" } %>
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
<% end %>
```

修正内容はこちら。

- `turbo_frame_tag quote do ~ end` で括って Turbo Frame/Stream で置き換えることができるようにする。
- Quoteの名前をクリックすると、 `data: { turbo_frame: "_top" }` の指定により、全画面を詳細画面で書き換える。
- [locals magic comment](https://github.com/rails/rails/pull/45602) を追加して必須のパラメーターを明記

こんな感じで動きます。

![詳細画面](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T20.25.18.gif)

続いて、削除の Turbo Frame/Stream 対応。

`app/controllers/quotes_controller.rb` の destroy メソッドの修正。 `format.turbo_stream` を追加。

```ruby
def destroy
    @quote.destroy

    respond_to do |format|
      format.html { redirect_to quotes_path, notice: "Quote was successfully destroyed." }
      format.turbo_stream
    end
  end
```

`app/views/quotes/destroy.turbo_stream.erb` の追加。

```erb
<%= turbo_stream.remove @quote %>
```

こんな感じで動きます。

![削除](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T20.25.44.gif)

これで詳細表示と削除が Turbo Frame/Stream に対応できました。

#### 新規作成

続いて、新規作成の Turbo Frame/Stream 対応です。

`app/views/quotes/new.html.erb` の修正。`turbo_frame_tag @quote do ~ end` でフォームを括ります。

```erb
<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>

  <div class="header">
    <h1>New quote</h1>
  </div>

  <%= turbo_frame_tag @quote do %>
    <%= render "form", quote: @quote %>
  <% end %>
</main>
```

`app/views/quotes/index.html.erb` の修正。「New quote」のリンクに `data: { turbo_frame: dom_id(Quote.new)` パラメーターを追加して、そのレスポンスを埋め込むための `<%= turbo_frame_tag Quote.new %>` を追加します。さらに、新規作成した Quote を追加するために `render @quotes` を `turbo_frame_tag "quotes" do ~ end` で括ります。

```erb
<main class="container">
  <div class="header">
    <h1>Quotes</h1>
    <%= link_to "New quote",
                new_quote_path,
                class: "btn btn--primary",
                data: { turbo_frame: dom_id(Quote.new) } %>
  </div>

  <%= turbo_frame_tag Quote.new %>

  <%= turbo_frame_tag "quotes" do %>
    <%= render @quotes %>
  <% end %>
</main>
```

`app/controllers/quotes_controller.rb` の create メソッドの修正。Turbo Frame/Stream の対応。

```ruby
  def create
    @quote = Quote.new(quote_params)

    if @quote.save
      respond_to do |format|
        format.html { redirect_to quotes_path, notice: "Quote was successfully created." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
```

最後は `app/views/quotes/create.turbo_stream.erb` の追加。先ほど修正した create メソッドのレスポンス。登録した Quote を一覧に追加して、新規作成のフォームを消しています。

```erb
<%= turbo_stream.prepend "quotes", @quote %>
<%= turbo_stream.update Quote.new, "" %>
```

こんな感じです。

![新規作成](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T20.34.35.gif)

これで新規作成も Turbo Frame/Stream に対応できました。

#### 編集

チュートリアルとは順番が異なってしまいますが、このタイミングで編集の Turbo Frame/Stream 対応です。単に読み飛ばしていしまっていました。失敗。

`app/views/quotes/edit.html.erb` の修正。フォームを `turbo_frame_tag @quote do ~ end` で括ります。

```erb
<main class="container">
  <%= link_to sanitize("&larr; Back to quote"), quote_path(@quote) %>

  <div class="header">
    <h1>Edit quote</h1>
  </div>

  <%= turbo_frame_tag @quote do %>
    <%= render "form", quote: @quote %>
  <% end %>
</main>
```

これだけです。

こんな感じで動きます。

![編集](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T20.40.28.gif)

編集も新規作成もフォームには一切手を加えずに SPA っぽくなりました。これは驚異的なことで、まずは従来のページ遷移を伴う CRUD を作って、あとで SPA っぽくする、みたいなことが簡単にできます。すごくワクワクしますね。

#### バグ修正

ちょっとフォームを触っていたところ 2 点、バグが見つかりました。
- Quote の名前を入力せずに Create quoteしたときのエラーメッセージに CSS のスタイルがあたっていない
- Quote の名前フォームの CSS スタイルがあたっていない

エラーメッセージのバグの原因は `@import` 漏れ。

`app/assets/stylesheets/application.postcss.css` に以下を追加。

```javascript
@import "./components/error-message.css";
```

名前フォームのバグは [simple\_formのclass cssがtailwindを使っている時に反映されない場合 \- kazuhitonakayama](https://scrapbox.io/kazuhitonakayama/simple_form%E3%81%AEclass_css%E3%81%8Ctailwind%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%A6%E3%81%84%E3%82%8B%E6%99%82%E3%81%AB%E5%8F%8D%E6%98%A0%E3%81%95%E3%82%8C%E3%81%AA%E3%81%84%E5%A0%B4%E5%90%88) を参考にして対応。 `tailwind.config.js` の `content` に `'./config/initializers/simple_form.rb'` を追加。

```javascript
/* 省略 */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './config/initializers/simple_form.rb'
  ],
/* 省略 */
```

こんな感じ。

![バグ修正](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T20.44.08.gif)

これでバグを 2 つとも潰すことができました。

#### ソート順の修正

次はソート順の修正です。

Quote を新規作成したときは一覧の一番上に表示されるのですが、

![新規作成したときは一覧の一番上](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T17.33.51.png)

リロードすると一覧の一番下に来てしまいます。

![リロードすると一番下](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T17.34.49.png)

そこで、一覧の順番を変えて、新しい Quote から順になるようにします。

まずはテスト `test/system/quotes_test.rb` を修正します。一覧の一番上に表示される Quote を `@quote` として扱っているため、Quote のうちで一番新しいもの = `Quote.last` に変えます。

```ruby
  setup do
    @quote = Quote.last
  end
```

テストを実行して失敗することを確認したら、アプリケーションを修正します。

チュートリアルではモデルに scope を追加しているのですが、ここではコントローラーを修正します。経験上、モデルに直接 scope を書きたくないからです。scope はシンプルで共通のものだけ (a minimum and only extract the common queries there)、という方針を見たことがありますが、それはとても難しいことなので、そもそも使わない、という方針にしています。

それでは `app/controllers/quotes_controller.rb` の index メソッドを次のように修正します。

```ruby
  def index
    @quotes = Quote.order(id: :desc)
  end
```

修正後はテストに成功することを確認します。

こんな感じで新規作成後にリロードしても順番が変わりません。

![ソート順](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T20.55.23.gif)

これでソート順が修正できました。

#### キャンセル

最後に新規作成をキャンセルできるようにします。

 テスト `test/system/quotes_test.rb` を追加して、

```ruby
  test "Cancel creating" do
    visit quotes_path
    click_on "New quote"

    assert(has_field?("Name"))

    click_on "Cancel"

    assert(has_no_field?("Name"))
  end
```

`app/views/quotes/_form.html.erb` にキャンセルボタン `link_to "Cancel", quotes_path, class: "btn btn--light"` を追加します。

```erb
<%# locals: (quote:) %>
<%= simple_form_for quote, html: { class: "quote form" } do |f| %>
  <% if quote.errors.any? %>
    <div class="error-message">
      <%= quote.errors.full_messages.to_sentence.capitalize %>
    </div>
  <% end %>

  <%= f.input :name, input_html: { autofocus: true } %>
  <%= link_to "Cancel", quotes_path, class: "btn btn--light" %>
  <%= f.submit class: "btn btn--secondary" %>
<% end %>
```

こんな感じ。

![キャンセル](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-5/SS_2024-09-14T20.58.40.gif)

これで新規作成をキャンセルできます。

### 今回のまとめ

今回は Turbo Frame/Stream を使って詳細表示、削除、新規作成、編集、キャンセルを SPA っぽくしました。

チュートリアルにも書いてありますが、JavaScript を一切書かずに SPA っぽいものができました。さらに tailwindcss を使っているため (基本的には) CSS も書かなくてもいいです。つまり、Ruby と HTML だけで SPA っぽいウェブアプリケーションが作れる、ということです。これは本当にすばらしいことです。

ソースコードは [takaokouji/quote-editor](https://github.com/takaokouji/quote-editor) においていますので、興味がある方は Watch していただけると励みになります。

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
