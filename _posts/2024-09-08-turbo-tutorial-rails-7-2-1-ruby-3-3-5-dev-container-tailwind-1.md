---
layout: single
title: "Turbo Rails Tutorial を Rails 7.2.1 / ruby 3.3.5 / Dev Container / tailwindcss でやってみた (1)"
categories: output
tags: ruby rails
toc: false
last_modified_at: 2024-09-08T17:00:00+0900
---

[mysql2のインストールにつまずいてしまったですが]({% post_url 2024-09-08-failed-mysql2-gem-ruby-3-3-5-aarch64 %}) 、[Turbo Rails Tutorial](https://www.hotrails.dev/turbo-rails) を [Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) と [tailwindcss](https://tailwindcss.com/) を利用してやってみようと思っていたんですよね。

うまくできるかわかりませんが、Let's Try!

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- Visual Studio Code 1.93.0
  - Dev Container 機能拡張をインストール済み
- [Homebrew](https://brew.sh/ja/)
- ruby 3.3.51
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

### [Turbo Rails tutorial introduction](https://www.hotrails.dev/turbo-rails/turbo-rails-tutorial-introduction)

rails new のコマンドラインオプションを次のように変えて、CSSフレームワークを tailwindcss 、DB を MySQL にする。

```bash
rails new quote-editor --css=tailwind --javascript=esbuild --database=mysql --devcontainer
# (以下、実行結果)
#       create
#       create  README.md
#       create  Rakefile
# (省略)
#   Add build:css script
#          run    npm pkg set scripts.build:css="tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --minify" from "."
#          run    yarn build:css from "."
#          run  bundle install --quiet
```

無事にコマンドが終了したら、Visual Studio Code で開く。

```bash
code quote-editor
```

Dev Container 機能拡張をインストール済みなので Dev Container を含んでいる旨が通知される。

![コンテナーで再度開く](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1/SS_2024-09-08T19.48.14.png)

「コンテナーで開く」 (2回目からはスクリーンショットのように 「コンテナーで再度開く」)ボタンを押して、しばらくすると MySQL や Redis 、 Selenium などの必要なソフトウェアが全部インストールされた Docker コンテナが構築される。たったこれだけで Rails の開発環境が整う。Dev Container / Docker (docker compose) は便利すぎる。

ただし、Selenium の Docker イメージは Apple Silicon 対応の `seleniarm/standalone-chromium` に変えないといけません。ちなみに Selenium は System Test で使います。

いったん、すべての修正をコミットしておきます (以下のコマンド相当の操作を Visual Studio Code のソース管理で行います)。

```bash
git add .
git commit -m 'feat: init'
```

ここでレポジトリが信頼できないため、ターミナルで以下のコマンドを実行してくれ、と通知されたのでそれに従いました (このあと、もう一度同じような通知があったのでコンテナを再構築するたびにこのコマンドの実行が必要なのかもしれません。面倒ですね)。

```bash
git config --global --add safe.directory /workspaces/quote-editor
```

`.devcontainer/compose.yaml` を `.devcontainer/compose.override.yaml` に複製 (コピペしてからリネーム) します。そして、以下のように変更します。

```yaml
services:
  selenium:
    image: seleniarm/standalone-chromium
```

そして、 `.devcontainer/devcontainer.json` の dockerComposeFile に先ほど作成した `compose.override.yaml` を追加します。

```diff
 diff --git a/.devcontainer/devcontainer.json b/.devcontainer/devcontainer.json
index 487620b..4757ef7 100644
--- a/.devcontainer/devcontainer.json
+++ b/.devcontainer/devcontainer.json
@@ -2,7 +2,10 @@
 // README at: https://github.com/devcontainers/templates/tree/main/src/ruby
 {
   "name": "quote_editor",
-  "dockerComposeFile": "compose.yaml",
+  "dockerComposeFile": [
+    "compose.yaml",
+    "compose.override.yaml"
+  ],
   "service": "rails-app",
   "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
```

ファイルを保存後、通知に従ってコンテナを再構築します。

![rebuildボタンを押す](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1/SS_2024-09-08T20.18.09.png)

念のため Docker Desktop で正しいイメージ (seleniarm/standalone-chromium) がインストールされていること確認します。

![selenium-1コンテナのImageがseleniarm/standalone-chromium:\<none\>になっている](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1/SS_2024-09-08T20.42.58.png)

この変更をコミットして続けます。

```bash
git add .
git commit -m 'faet: seleniarm'
```

rails 7.2.1 だと `gem "turbo-rails"` はすでに追加されていたので `Gemfile` は変更しませんでした。

Visual Studio Code のターミナルで以下を実行。

```bash
bin/setup
bin/dev
# (以下、実行結果の一部)
# 11:56:46 js.1   | $ esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets --watch
# 11:56:46 css.1  | $ tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --minify --watch
# 11:56:46 js.1   | /bin/sh: 1: esbuild: not found
# 11:56:46 css.1  | /bin/sh: 1: tailwindcss: not found
```

エラーです。`bin/dev` はサーバーの起動コマンドなのですが、`esbuild` と `tailwindcss` がないためサーバーを起動できませんでした。

よくよく考えてみると、 `bundle install` や `yarn install` を行ったのは rails new のときなのでコンテナではなくてローカル。そのため、コンテナ上でもあらためてそれらを実行する必要があるはず。

まずは bundle から。`bundle list` で確認したところ gem はすべてインストール済みだった。bundle は OK。

```text
$ bundle list
Gems included by the bundle:
  * actioncable (7.2.1)
  * actionmailbox (7.2.1)
  * actionmailer (7.2.1)
(省略)
  * websocket-extensions (0.1.5)
  * xpath (3.2.0)
  * zeitwerk (2.6.18)
Use `bundle info` to print more detailed information about a gem
```

次に yarn。こちらはさっぱりだめでした。

```text
$ yarn global list --depth=0
yarn global v1.22.22
Done in 0.02s.

$ yarn list --depth=0
yarn list v1.22.22
Done in 0.02s.
```

rails new のときの実行ログを眺めたところ、以下をコンテナ上で再実行しないといけなさそう。コマンド的には package.json にこれらのパッケージを記載したほうが良さそうなのですが、記載されていない理由があるのだろうか。

```text
(省略)
  Install esbuild
         run    yarn add --dev esbuild from "."
(省略)
  Install Turbo
         run    yarn add @hotwired/turbo-rails from "."
(省略)
  Install Stimulus
         run    yarn add @hotwired/stimulus from "."
(省略)
  Install Tailwind (+PostCSS w/ autoprefixer)
(省略)
         run    yarn add tailwindcss@latest postcss@latest autoprefixer@latest from "."
```

それぞれのコマンドをコンテナ上でも実行します。必要なパッケージがインストールされます。

```bash
yarn add --dev esbuild
yarn add @hotwired/turbo-rails
yarn add @hotwired/stimulus
yarn add tailwindcss@latest postcss@latest autoprefixer@latest

yarn list --depth=0
# (以下、実行結果)
# yarn list v1.22.22
# ├─ @alloc/quick-lru@5.2.0
# ├─ @esbuild/aix-ppc64@0.23.1
# ├─ @esbuild/android-arm@0.23.1
# (省略)
# ├─ wrap-ansi-cjs@7.0.0
# ├─ wrap-ansi@8.1.0
# └─ yaml@2.5.1
# Done in 0.07s.
```

あらためてサーバーを起動します。

```text
$ bin/dev
12:25:33 web.1  | started with pid 14095
12:25:33 js.1   | started with pid 14096
12:25:33 css.1  | started with pid 14100
12:25:33 js.1   | yarn run v1.22.22
(省略)
12:25:34 web.1  | * Listening on http://127.0.0.1:3000
12:25:34 web.1  | * Listening on http://[::1]:3000
12:25:34 web.1  | Use Ctrl-C to stop
12:25:34 css.1  |
12:25:34 css.1  | Done in 156ms.
```

よし！いつもの rails server ですね。

早速ブラウザでアクセスしてみます。せっかくなので「エディタでのプレビュー」を選択して、Visual Studio Code 上でプレビュー。これは Chromium ベースのエディタの強みですね。

![エディタでのプレビューボタンを押す](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1/SS_2024-09-08T21.29.40.png)

...。えっ、真っ白なんですけど！？

![トップ画面に何も表示されない](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1/SS_2024-09-08T21.32.46.png)

**いつもの Yay! はどこいったの！？**

![Yay!You're on Rails!](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1/SS_2024-09-08T21.48.07.png)

恐る恐る Chrome で http://localhost:3000 にアクセスしてみると...

![Railsのトップ画面](/assets/images/turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-1/SS_2024-09-08T21.54.03.png)

いつもの Yay! じゃないのですが、ちゃんと表示されていました。

Visual Studio Code 上のシンプルブラウザーだとダメみたい。Turbo が原因だと予想していますが、シンプルブラウザーのデバッグ方法がわからないため、深追いはやめます。Turbo を使っているウェブサイトでは Visual Studio Code のシンプルブラウザーは使えないということを覚えておこう。

```bash
git add .
git commit -m 'feat: install esbuild, tailwindcss'
```

今回はここまで。ソースコードは [takaokouji/quote-editor](https://github.com/takaokouji/quote-editor) においています。

Dev Container は簡単そうに見えて、やってみるとそれなりに険しい道ですね。やはりやってみないとわからないことは多いと痛感しました。

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
