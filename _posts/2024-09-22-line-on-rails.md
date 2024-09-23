---
layout: single
title: "Ruby on RailsのアプリケーションでLINEログイン・メッセージ送信をできるようにする"
categories: output
tags: ruby rails line
toc: true
last_modified_at: 2024-09-22T12:00:00+0900
---

現代のコミュニケーション手段として [LINE](https://line.me/ja/) はなくてはならないものになりました。今回は、その LINE を Ruby on Rails のアプリケーション (以降、Rails アプリ) から使えるようにします。

ソースコードは [takaokouji/everdiary-line](https://github.com/takaokouji/everdiary-line) にあります。

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- [Homebrew](https://brew.sh/ja/)
- Visual Studio Code 1.93.0
  - Dev Container 機能拡張をインストール済み
- Docker Desktop 4.34.2
- ruby 3.3.5
  - [anyenv](https://github.com/anyenv/anyenv) で [rbenv](https://github.com/rbenv/rbenv) をインストール
  - ruby 3.3.5 を global に設定済み ( `rbenv global 3.3.5` )
- rails 7.2.1 gem
  - `gem install rails`
- 他のソフトウェアは Docker コンテナ上にインストール
- LINE アカウント
  - スマホで LINE を使えるようにしておきます。

### Rails アプリ

今回 LINE を組み込むのは、1行日記を記録する Everdiary (エバーダイアリー) という Rails アプリです。

Everdiary は、ユーザー(users)と日記(diaries)の2つのテーブルのみ。そして、日記には、日記を書いた日(written_on)と255文字以下の日記(content)の2つのカラムのみ、という単純なものにします。

- ユーザーテーブル (users)
  - Devise が自動生成するカラムのみ
- 日記テーブル (diaries)
  - written_on: 日記を書いた日
  - content: 日記
  - user_id: ユーザーとの関連

早速、作っていきます。

初期セットアップ。ターミナルで実行します。

```bash
rails new everdiary --css=tailwind --javascript=esbuild --database=mysql --devcontainer --skip-bundle --skip-git
```

Visual Studio Code で everdiary を開き、Docker コンテナを構築。以降はコンテナ上で作業します。

```bash
code everdiary
```

![Visual Studio Code でコンテナ起動](/assets/images/line-on-rails/SS_2024-09-23T18.17.39.png)

コンテナ上で Rails の再セットアップ。`rm bin/rails` がポイントです。こうすることで、tailwindcss や esbuild のインストールをコンテナ上で再現できます。

```bash
rm bin/rails
bundle exec rails new . -f -n everdiary --css=tailwind --javascript=esbuild --database=mysql --devcontainer
bin/bundle add tailwindcss-rails
bin/dev
```

ブラウザで表示後、 *bin/dev を control-c で停止させます*。

モデルの作成やDeviseの導入。ターミナルで以下のコマンドを実行する。

```bash
bin/bundle add devise
bin/rails generate devise:install
bin/rails generate devise User
bin/rails generate scaffold Diary written_on:date:uniq content:string user:references --skip-jbuilder
bin/rails db:migrate
```

`app/models/user.rb` を修正する。

```ruby
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :diaries, dependent: :destroy # ←この行を追加
end
```

`app/controllers/application_controller.rb` を修正する。

```ruby
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :devise_controller? # ←この行を追加
end
```

`app/controllers/diaries_controller.rb` の修正。1行日記とログインユーザーを紐づけます。

```ruby
# (省略)
    def diary_params
      params.require(:diary).permit(:written_on, :content).merge(user: current_user) # ←この行を修正
    end
end
```

`app/views/diaries/_form.html.erb` の修正。user_id は入力不要なので削除します。

```erb
<%# 省略 %>
  <div class="my-5">
    <%= form.label :content %>
    <%= form.text_field :content, class: "block shadow rounded-md border border-gray-400 outline-none px-3 py-2 mt-2 w-full" %>
  </div>

  <%# ここに記述されていた user_id のフォームを削除する %>
  <div class="inline">
    <%= form.submit class: "rounded-lg py-3 px-5 bg-blue-600 text-white inline-block font-medium cursor-pointer" %>
  </div>
<%# 省略 %>
```

`config/routes.rb` を修正。 <http://localhost:3000/> にアクセスしたときや、サインイン後に1行日記の一覧を表示するように修正。

```ruby
# (省略)
  # Defines the root path route ("/")
  root "diaries#index"
end
```

`app/views/layouts/_navbar.html.erb` の作成。サインイン後にメールアドレスとサインアウト用のリンクを表示する。

```erb
<header class="flex items-center shadow-lg py-2 px-2 mb-10">
  <% if user_signed_in? %>
    <div class="font-bold mr-3">
      <%= current_user.email %>
    </div>
    <%= button_to "Sign out", destroy_user_session_path, method: :delete,
      class: "rounded-md py-1 px-3 border-solid border-[1px] border-black block" %>
  <% end %>
</header>
```

`app/views/layouts/application.html.erb` の修正。

```erb
<%# 省略 %>
  <body>
    <%= render "layouts/navbar" %> <%# ←この行を追加 %>
    <%= yield %>
  </body>
<%# 省略 %>
```

サーバーを起動して動作確認。

```bash
bin/dev
```

動作確認の内容は以下のようなものです。

- <http://localhost:3000/> にアクセスすると、サインイン画面にリダイレクト
  - サインイン画面と次のサインアップ画面にはスタイルが全くあたっていない。が、ここでは気にしないことにします。
- サインアップを押して、メールアドレスとパスワードを入力して、ユーザーの作成

![サインアップとサインイン](/assets/images/line-on-rails/SS_2024-09-23T19.02.59.gif)

- 日記の一覧画面を表示
- 日記の作成・編集・削除

![日記のCRUD](/assets/images/line-on-rails/SS_2024-09-23T19.03.41.gif)

これで必要最低限の機能を持った Rails アプリケーションができました。

### LINE ログイン・メッセージ送信の流れ

LINE のチャネルの登録から LINE ログインしてメッセージを送信するまでの流れは次のようになります。

![LINE ログイン・メッセージ送信の流れ](/assets/images/line-on-rails/line_login_messaging_flow.png)

### LINE ログイン・Messaging APIチャンネルの作成

LINE ログインとメッセージ送信には次の情報が必要です。

- LINE Developers/プロバイダー/LINEログイン
  - チャネルID
  - チャネルシークレット
- LINE Developers/プロバイダー/Messaging API
  - チャネルシークレット
  - チャネルアクセストークン

まずは [LINE Developersコンソール](https://developers.line.biz/console/) でプロバイダーと、LINE ログインチャネルを登録します。

- LINE アカウントで LINE Developers コンソールにログイン
- プロバイダーの登録
  - プロバイダーは [サービス提供者を表している](https://note.com/andyshow/n/n62018b9b1a8d) という説明もあったので、企業名や屋号のような少し規模の大きなものにすると良さそうです。
- LINE ログインチャネルの登録
  - こちらは開発用と本番用の2つを作ることになるため、everdiary-login-dev、everdiary-login-prod にします。

これで、LINE ログインのチャネルIDとチャネルシークレットを用意できました。

次に [LINE 公式アカウント](https://manager.line.biz/) で LINE 公式アカウントと Messaging API の利用を開始します。

- LINE 公式アカウントの作成
- LINE 公式アカウント上の設定から「Messaging APIを利用する」

もう一度 [LINE Developersコンソール](https://developers.line.biz/console/) でチャネルアクセストークンを発行します。

- LINE Developersコンソールでプロバイダーを選択する
- Messaging APIのチャネルを選択する
- Messaging API設定タブを表示して、チャンネルアクセストークン(長期)を発行する

これで、LINE Messaging APIのチャネルシークレットとチャネルアクセストークンを用意できました。

それぞれを `.env` を作成して記載します。

```shell
# LINE ログイン
LINE_KEY="チャネルID"
LINE_SECRET="チャネルシークレット"

# LINE Messaging API
LINE_CHANNEL_SECRET="チャネルシークレット"
LINE_CHANNEL_TOKEN="チャンネルアクセストークン"
```

### ngrokのセットアップ

LINE ログインの動作確認で利用する ngrok をセットアップします。ngrok を使えば、http://localhost:3000/ にインターネットからアクセスできるようになります。

まずは [ngrok](https://ngrok.com/) にサインアップ(sign up)します。用途などのアンケートにいくつか回答すると、サインアップできます。

続いて、サインアップ後の画面に従って、ngrokアプリケーションをインストールします。

```bash
brew install ngrok/ngrok/ngrok
ngrok config add-authtoken xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# (↑のxxx...はngrokの画面のものに置き換えること。以下、実行結果)
# Authtoken saved to configuration file: /Users/kouji/Library/Application Support/ngrok/ngrok.yml
```

最後に `config/environments/development.rb` を修正して、 ngrok からアクセス可能にします。

```ruby
# (省略)
  # Apply autocorrection by RuboCop to files generated by `bin/rails generate`.
  # config.generators.apply_rubocop_autocorrect_after_generate!

  config.hosts << /.*\.ngrok-free\.app/
end
```

これでセットアップできました。

今ではないのですが、今後 LINE ログインを試す前に、Visual Studio Code ではない (Docker 上ではない) 通常のターミナルで以下のコマンドを実行します。その後に表示された URL `https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app` にアクセスすることで、インターネットから開発中のアプリケーションにアクセスできるようになります。

```text
$ ngrok http http://localhost:3000

ngrok                                    (Ctrl+C to quit)

Share what you're building with ngrok https://ngrok.com/share-your-ngrok-story

Session Status                online
Account                       Kouji Takao (Plan: Free)
Version                       3.16.0
Region                        Japan (jp)
Latency                       25ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app -> http://localhost:3000
                              ↑↑↑ この URL
```

### LINE ログイン

これでようやく準備が整いました。
Everdiary を LINE ログインに対応させ、LINE のユーザーID (uid) を Rails アプリのユーザーに紐づけます。

まずは LINE のユーザーIDを格納するテーブルを作ります。

```bash
bin/rails generate model MyLineUser uid:string user:references:uniq
bin/rails db:migrate
```

次に LINE ログインで利用する gem をインストールします。

```bash
bin/bundle add omniauth-line omniauth-rails_csrf_protection dotenv
```

`config/initializers/devise.rb` に LINE ログインの設定を追加します。

```ruby
# (省略)
  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'
  config.omniauth :line, ENV["LINE_KEY"], ENV["LINE_SECRET"] # ← この行を追加

# (省略)
```

`app/models/user.rb` を修正。

```ruby
# (省略)

  has_many :diaries, dependent: :destroy
  has_one :my_line_user, dependent: :destroy # ←この行を追加
end
```

`app/models/my_line_user.rb` を修正。

```ruby
class MyLineUser < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[line] # ←この行を追加

  belongs_to :user
end
```

`config/routes.rb` を修正。

```ruby
Rails.application.routes.draw do
  resources :diaries
  devise_for :users
  devise_for :my_line_users, controllers: { omniauth_callbacks: "omniauth_callbacks" } # ←この行を追加
# (省略)
```

LINE ログインによって呼び出されるコントローラーを作成します。

```bash
bin/rails generate controller omniauth_callbacks
```

`app/controllers/omniauth_callbacks_controller.rb` を修正します。ここではエラー処理は考えず、すべてうまくいく前提にしています。

```ruby
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    auth = request.env["omniauth.auth"]
    MyLineUser.create!(user: current_user, uid: auth["uid"])
    redirect_to root_path
  end
end
```

`app/views/layouts/_navbar.html.erb` を修正して LINE 連携用のリンクを追加します。 `data: {turbo: "false"}` がポイントで、これを指定しないと CORS のエラーで LINE ログインに失敗します。

```erb
<header class="flex items-center shadow-lg py-2 px-2 mb-10">
  <% if user_signed_in? %>
    <div class="font-bold mr-3">
      <%= current_user.email %>
    </div>
<%# ここから %>
    <% if current_user.my_line_user %>
      <div class="mr-3">
        LINE Linked
      </div>
    <% else %>
      <%= button_to "LINE Login", my_line_user_line_omniauth_authorize_path, data: {turbo: "false"},
        class: "rounded-md py-1 px-3 border-solid border-[1px] border-black block mr-3" %>
    <% end %>
<%# ここまで %>
    <%= button_to "Sign out", destroy_user_session_path, method: :delete,
      class: "rounded-md py-1 px-3 border-solid border-[1px] border-black block" %>
  <% end %>
</header>
```

なお、「LINE Linked」と「LINE Login」の日本語は、それぞれ「LINE連携済」「LINE連携」を想定しています。Everdiary は i18n 対応は行わないのですが、いちおう、日本語のラベルも考えています。

これで LINE ログイン対応の修正は終わりました。

動作確認のためにサーバーを起動して、

```bash
bin/dev
```

さらに ngrok を起動します。

```text
$ ngrok http http://localhost:3000

ngrok                                                         (Ctrl+C to quit)

Share what you're building with ngrok https://ngrok.com/share-your-ngrok-story

Session Status                online
Account                       Kouji Takao (Plan: Free)
Version                       3.16.0
Region                        Japan (jp)
Latency                       25ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app -> http://localhost:3000
                              ↑↑↑ この URL
```

そして、↑の `Forwarding` に表示されている `https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app` に `/my_line_users/auth/line/callback` を追加して、 [LINE Developersコンソール](https://developers.line.biz/console/) のLINE ログインチャネルのコールバックURLに指定します。面倒ですが *ngrok を起動するたびに設定してください*。

- [LINE Developers コンソール](https://developers.line.biz/ja/) にアクセスする
- プラバイダーを選択する
- LINE ログインチャネルを選択する
- LINE ログイン設定タブを選択する
- 「ウェブアプリでLINEログインを利用する」のにある「コールバックURL」に ↑ の <https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app/my_line_users/auth/line/callback> を指定する。

それでは、ブラウザで <https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app/> にアクセスしてサインインします。そして、LINE Login ボタンを押します。
ここでのポイントは <http://localhost:3000/> ではなく ngrok の URL にアクセスすることです。

![LINE ログイン](/assets/images/line-on-rails/SS_2024-09-23T21.43.23.gif)

LINE ログインに成功して LINE のユーザーID (uid) を DB に保存できましたね。

LINE 連携を解除する方法を用意していないため、もう一度 LINE ログインを試す場合は、 rails console で MyLineUser を削除します。

```text
$ bin/rails console
> MyLineUser.last.destroy
```

最後に LINE ログインを公開済みに変えます。これですべての LINE ユーザーがログインできるようになります。

- [LINE Developers コンソール](https://developers.line.biz/ja/) にアクセスする
- プロバイダーを選択する
- LINE ログインチャネルを選択する
- ↓の画像を参考にして公開済みに変更する

![公開済みに変える](/assets/images/line-on-rails/SS_2024-09-23T21.49.41.png)

### LINE メッセージ送信

続いて、日記を登録したときに LINE でメッセージ送信できるようにします。まったく便利な機能ではありませんが、メッセージ送信のテストなので割り切って作りましょう。

LINE のメッセージ送信で使う gem をインストールします。

```bash
bin/bundle add line-bot-api
```

`app/models/my_line_messaging.rb`　の作成。これは `MyLineMessaging.push_text_message(uid: current_user.my_line_user&.uid, text: "送信するメッセージ")` のように使います。

```ruby
class MyLineMessaging
  class << self
    def push_text_message(uid:, text:)
      new.push_text_message(uid:, message: { type: "text", text: })
    end
  end

  def push_text_message(uid:, message:)
    line_bot_client.push_message(uid, message)
  end

  private

  def line_bot_client
    @line_bot_client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
```

`app/controllers/diaries_controller.rb` の修正。`if current_user.my_line_user&.uid` でチェックして、LINE ログイン済みであればメッセージを送ります。

```ruby
# (省略)
  def create
    @diary = Diary.new(diary_params)

    respond_to do |format|
      if @diary.save
        # ここから
        if current_user.my_line_user&.uid
          text =  "#{@diary.written_on.strftime("%Y/%m/%d(%a)")} #{@diary.content}"
          MyLineMessaging.push_text_message(uid: current_user.my_line_user.uid, text:)
        end

        # ここまで
        format.html { redirect_to @diary, notice: "Diary was successfully created." }
        format.json { render :show, status: :created, location: @diary }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end
# (省略)
```

これで新しい日記を書くと LINE でメッセージが送信されます。イェイ
まぁ、とりあえず、メッセージを送信できることは確認できましたね。

![LINEメッセージ送信](/assets/images/line-on-rails/SS_2024-09-23T21.57.11.png)

### おわりに

LINEログインとメッセージ送信。ここまでは先人の知恵をお借りしながら、無事にたどり着くことができました。
問題はここからです。本番環境でLINE ログインを行うためには HTTPS 通信を実現しなければいけません。

ここまでのソースコードは [takaokouji/everdiary-line](https://github.com/takaokouji/everdiary-line) に置いておきます。

次回は、 Everdiary を aws 上にデプロイして、 ngrok なしで HTTPS 通信を行い、 LINE ログインとメッセージ送信を実現したいと思います。

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
