---
layout: single
title: "Ruby on RailsのアプリケーションでLINEログイン・メッセージ送信をできるようにする"
categories: output
tags: ruby rails line
toc: true
last_modified_at: 2024-09-22T12:00:00+0900
---

現代のコミュニケーション手段として [LINE](https://line.me/ja/) はなくてはならないものになりました。今回は、その LINE を Ruby on Rails のアプリケーション (以降、Rails アプリ) から使えるようにします。

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

### Rails アプリ

今回 LINE を組み込むのは、1行日記を記録する Everdiary (エバーダイアリー) という Rails アプリです。Everdiary は、ユーザー(users)と日記(diaries)の2つのテーブルのみ。そして、日記には、日記を書いた日(written_on)と255文字以下の日記(content)の2つのカラムのみ、という単純なものにします。

- ユーザー (users) テーブル
  - Devise が自動生成するカラムのみ
- 日記 (diaries) テーブル
  - written_on: 日記を書いた日
  - content: 日記
  - user_id: ユーザーとの関連

早速、作っていきます。

初期セットアップ。ターミナルで実行します。

```bash
rails new everdiary --css=tailwind --javascript=esbuild --database=mysql --devcontainer --skip-bundle --skip-git
```

Visual Studio Codeで Docker コンテナを構築。以降はコンテナ上で作業します。

```bash
code everdiary
```

![Visual Studio Code でコンテナ起動](/assets/images/line-on-rails/SS_2024-09-23T18.17.39.png)

コンテナ上で Rails の再セットアップ。こうすることで、tailwindcss や esbuild のインストールをコンテナ上で再現できる。

```bash
rm bin/rails
bundle exec rails new . -f -n everdiary --css=tailwind --javascript=esbuild --database=mysql --devcontainer
bin/bundle add tailwindcss-rails
bin/dev
```

ブラウザで表示後、bin/dev を control-c で停止しておく。

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

`config/routes.rb` を修正。 <http://localhost:3000/> にアクセスしたときや、ログインしたときに1行日記の一覧を表示するように修正。

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

### LINE ログイン・メッセージ送信の仕組み

WIP

### LINE ログイン・Messaging APIチャンネルの作成

- LINE アカウントの作成
- LINE Developers にログイン
- プロバイダーの作成
- LINE ログインの新規チャネルの作成
- LINE 公式アカウントの作成
- LINE 公式アカウント上の設定から「Messaging APIを利用する」
- LINE Developersの作成したプロバイダーに戻る
- Messaging APIのチャネルを選択する
- Messaging API設定タブを表示して、チャンネルアクセストークン(長期)を発行する。

必要な情報

- LINE Developers/プロバイダー/LINEログイン
  - チャネルID
  - チャネルシークレット
- LINE Developers/プロバイダー/Messaging API
  - チャネルシークレット
  - チャネルアクセストークン

### ngrok

開発しているときの LINE ログインのテストで利用する ngrok をセットアップします。

[ngrok](https://ngrok.com/) にサインアップ(sign up)する。

WIP: サインアップの説明

サインアップ後の画面に従って、ngrokアプリケーションをインストールする。

WIP: ngrok config add-authtoken xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx の説明。xxxxxをそのまま入力してしまうのを防ぐ。

```bash
brew install ngrok/ngrok/ngrok
ngrok config add-authtoken xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# (以下、実行結果)
# Authtoken saved to configuration file: /Users/kouji/Library/Application Support/ngrok/ngrok.yml
```

`config/environments/development.rb`

```ruby
# (省略)
  config.hosts << /.*\.ngrok-free\.app/
end
```

これでセットアップできました。

今ではないのですが、今後 LINE ログインを試す前に以下のコマンドを実行します。すると、表示された URL `https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app` にアクセスすることで、インターネットから開発中のアプリケーションにアクセスできるようになります。

```bash
ngrok http http://localhost:3000
```

### LINE ログイン

まずは LINE ログインを行い、LINEのユーザーID (uid) を Rails アプリケーションのユーザーに紐づけます。

LINEのユーザーIDを格納するテーブルを作ります。

```bash
bin/rails generate model MyLineUser uid:string user:references
```

`db/migrate/YYYYmmddHHMMSS_create_my_line_users.rb`。userにuniq制約を追加。

```ruby
class CreateMyLineUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :my_line_users do |t|
      t.string :uid
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
```

```bash
bin/rails db:migrate
```

```bash
bin/bundle add omniauth-line omniauth-rails_csrf_protection dotenv
```

`.env`。LINE Developers/プロバイダー/LINEログインのチャネルID、チャネルシークレットをそれぞれLINE_KEY、LINE_SECRETに設定する。


```shell
LINE_KEY="チャネルID"
LINE_SECRET="チャネルシークレット"
```

`config/initializers/devise.rb`

```ruby
# (省略)
  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'
  config.omniauth :line, ENV["LINE_KEY"], ENV["LINE_SECRET"]

# (省略)
```

`app/models/user.rb`。 `has_one :my_line_user, dependent: :destroy` を追加。

```ruby
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :my_line_user, dependent: :destroy
  has_many :diaries, dependent: :destroy
end
```

app/models/my_line_user.rb

```ruby
class MyLineUser < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[line]

  belongs_to :user
end
```

`config/routes.rb`。 `devise_for :my_line_users, ...` を追加。

```ruby
Rails.application.routes.draw do
  devise_for :users
  devise_for :my_line_users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  resources :diaries
# (省略)
```

```bash
bin/rails generate controller omniauth_callbacks
```

```ruby
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    auth = request.env["omniauth.auth"]
    MyLineUser.create!(user: current_user, uid: auth["uid"])
    redirect_to root_path
  end
end
```

`app/views/layouts/_navbar.html.erb`。LINE連携用のリンクを追加。ついでにサインアウトのリンクも追加。 `data: {turbo: "false"}` がポイントでこれを指定しないと CORS のエラーで LINE ログインに失敗します。

```erb
<header class="flex items-center shadow-lg py-2 px-2 mb-10">
  <% if user_signed_in? %>
    <div class="font-bold mr-3">
      <%= current_user.email %>
    </div>
    <% if current_user.my_line_user %>
      <div class="mr-3">
        LINE Linked
      </div>
    <% else %>
      <%= button_to "LINE Login", my_line_user_line_omniauth_authorize_path, data: {turbo: "false"},
        class: "rounded-md py-1 px-3 border-solid border-[1px] border-black block mr-3" %>
    <% end %>
    <%= button_to "Sign out", destroy_user_session_path, method: :delete,
      class: "rounded-md py-1 px-3 border-solid border-[1px] border-black block" %>
  <% end %>
</header>
```

`app/views/layouts/application.html.erb`。`<%= render "layouts/navbar" %>` を追加。

```erb
<%# 省略 %>
  <body>
    <%= render "layouts/navbar" %>
    <%= yield %>
  </body>
<%# 省略 %>
```

```bash
bin/dev
```

さらに ngrok を起動します。

```text
$ ngrok http http://localhost:3000

ngrok                                                                                                                                                                                           (Ctrl+C to quit)

Share what you're building with ngrok https://ngrok.com/share-your-ngrok-story

Session Status                online
Account                       Kouji Takao (Plan: Free)
Version                       3.16.0
Region                        Japan (jp)
Latency                       25ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app -> http://localhost:3000
```

`Forwarding` に表示されている `https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app` を LINE ログインチャネルのコールバックURLに指定します。

- [LINE Developers コンソール](https://developers.line.biz/ja/)
- LINE ログインチャネル
- LINE ログイン設定タブ
- ウェブアプリでLINEログインを利用する
- コールバックURLに <https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app/my_line_users/auth/line/callback> を指定する。

これで準備ができました。

<https://xxx-xxx-xxx-xxx-xxx.ngrok-free.app/> にアクセスして、サインイン後に LINE Login します。
ポイントは <http://localhost:3000/> ではなく ngrok の URL でアクセスすることです。

無事、ログインできて LINE のユーザーID (uid) を DB に保存できました。

もう一度 LINE ログインを試したければ、 rails console で MyLineUser を DB から削除します。

```text
$ bin/rails console
> MyLineUser.last.destroy
```

ここでひとつ疑問が。チャンネルは公開していないのですが、問題ないのだろうか。とりあえず次に進みます。

### LINE メッセージ送信

日記を登録したときに LINE でメッセージ送信できるようにします。

```bash
bin/bundle add line-bot-api
```

`.env`。LINE Developers/プロバイダー/Messaging APIのチャネルシークレット、チャネルアクセストークンをそれぞれLINE_CHANNEL_SECRET、LINE_CHANNEL_TOKENに設定します。

```shell
# (省略)
LINE_CHANNEL_SECRET="チャネルシークレット"
LINE_CHANNEL_TOKEN="チャンネルアクセストークン"
```

`app/models/my_line_messaging.rb`。これは `MyLineMessaging.push_text_message(uid: current_user.my_line_user.uid, text: "送信するメッセージ")` のように使います。

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

`app/controllers/diaries_controller.rb`。`if current_user.my_line_user&.uid` でチェックして、LINE ログイン済みであればメッセージを送ります。

```ruby
# (省略)
  def create
    @diary = Diary.new(diary_params)

    respond_to do |format|
      if @diary.save
        if current_user.my_line_user&.uid
          text =  "#{@diary.written_on.strftime("%Y/%m/%d(%a)")} #{@diary.content}"
          MyLineMessaging.push_text_message(uid: current_user.my_line_user.uid, text:)
        end

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

これで新しい日記を書くと LINE にメッセージが送られるようになります。

### LINE メッセージ受信

最後に LINE からメッセージを受信できるようにします。メッセージを受信したら最近の日記を表示することにします。

WIP

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
