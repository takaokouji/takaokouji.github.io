---
layout: single
title: "LINEログイン・メッセージ送信可能なRailsアプリをデプロイする"
description: "LINE ログイン、LINE Messaging API によるメッセージ送信が可能な Rails アプリを Kamel を使って EC2 にデプロイします。HTTPS 通信では無料の Let's Encrypt のSSL証明書を利用します。"
lang: ja_JP
categories: output
tags: ruby rails line kamel ec2
toc: true
last_modified_at: 2024-09-29T18:00:00+0900
---

[前回の続き]({% post_url 2024-09-22-line-on-rails %}) です。LINE ログイン、LINE Messaging API によるメッセージ送信が可能な Rails アプリ Everdiary を EC2 にデプロイします。今回初めて [Kamel](https://kamal-deploy.org/) を使ってデプロイしてみようと思います。また、HTTPS 通信には [Let's Encrypt](https://letsencrypt.org/ja/) の SSL 証明書を利用します。

ソースコードは [takaokouji/everdiary-line](https://github.com/takaokouji/everdiary-line) にあります。

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- [Homebrew](https://brew.sh/ja/)
- [Visual Studio Code 1.93.0](https://code.visualstudio.com/) (以降、VSCode と記載します)
  - Dev Container 機能拡張をインストール済み
- [Docker Desktop](https://docs.docker.com/desktop/) 4.34.2
  - <https://docs.docker.com/desktop/install/mac-install/>
- ruby 3.3.5
  - [anyenv](https://github.com/anyenv/anyenv) で [rbenv](https://github.com/rbenv/rbenv) をインストール
  - ruby 3.3.5 を global に設定済み ( `rbenv global 3.3.5` )
- rails 7.2.1 gem
  - `gem install rails`
- 他のソフトウェアは Docker コンテナ上にインストール
- LINE アカウント
  - スマホで LINE を使えればOK
- **【NEW】** [AWSのアカウント](https://aws.amazon.com/jp/free/)
- **【NEW】** [Docker Hubのアカウント](https://app.docker.com/signup)
- **【NEW】** 独自ドメイン
  - [お名前.com](https://www.onamae.com/) や AWS Route53 で取得する

### 情報収集

今回、初めて [Kamal](https://kamal-deploy.org/) を使うので、情報収集を入念に行いました。

- [Kamal 公式サイト](https://kamal-deploy.org/)
- [Deploying Rails on a single server with Kamal](https://nts.strzibny.name/deploying-rails-single-server-kamal/)
- [Kamal on Amazon EC2](https://jasonfleetwoodboldt.com/courses/rails-7-crash-course/kamal-on-amazon-ec2/)
- [Kamal で Rails アプリを Ubuntu サーバーにデプロイする](https://note.com/usutani/n/n890c38e68eb7)

しかしながら、さあやるぞってタイミングで [Kamal のバージョン 2.0.0](https://github.com/basecamp/kamal/releases/tag/v2.0.0) がリリースされました (変更点は[こちら](https://kamal-deploy.org/docs/upgrading/overview/))。

新バージョンのリリース自体はウェルカムなのですが、調べた情報がそのままでは使えなくなってしまいました。でもそれも人柱になるチャンスだと思って、Kamal 2.0.0 でのデプロイに挑戦していきます。

### 事前準備

Kamal でのデプロイに先立って、用意しておくアカウントや情報がいくつかあります。

- Docker のアカウント
  - GitHub アカウントでのサインアップを想定しています。

![Dockerアカウントのサインアップ](/assets/images/deploy-line-on-rails/docker_create_account_SS_2024-09-28T16.39.05.png)

- AWS のアカウント
  - デプロイ先は AWS の EC2 を想定してます。
- ドメイン
  - Everdiary を提供するドメインが必要です。ここでは、お名前.com でドメインを登録し、Everdiary はサブドメインで提供することを想定しています。
  - ドメイン: smalruby.app
  - サブドメイン: everdiary.smalruby.app

### Kamalのインストール

[Kamal公式サイト](https://kamal-deploy.org/docs/installation/) を参考にして Kamal をインストールします。

VSCode で Everdiary を開きます (`code path/to/everdiary`)。ただし、このタイミングでは **コンテナは使いません**。すでにコンテナで開いている場合はワークスペースをローカルで開き直してください。

`.devcontainer/devcontainer.json` を修正して、コンテナ上で docker build コマンドを実行できるようにします。このコマンドは Kamal が使います。

```json
// (省略)

  // Features to add to the dev container. More info: https://containers.dev/features.
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/rails/devcontainer/features/activestorage": {},
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/rails/devcontainer/features/mysql-client": {}, # ← ,を追加
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {} # ← この行を追加
  },

// (省略)
```

修正し終えたら、ワークスペースを **コンテナで再度開きます**。表示されたダイアログの **Rebuildボタン** を押して、コンテナをリビルドします (エラーが表示されたらリトライする)。

コンテナが起動したら、VSCode のターミナルで次のコマンドを実行します。

```bash
./bin/bundle add kamal --group development
```

次に Kamal の初期設定ファイルを自動生成します。

```bash
bundle exec kamal init
```

ここから先は手探りで設定していきます。そのため、いつでも初期状態に戻せるように、生成したファイル群をそのままコミットしておきます。

```bash
git add .
git commit -m 'feat: kamal init'
```

### AWS EC2インスタンスの起動

AWS の EC2 インスタンスを用意して、起動します。

サインインして、

![サインイン](/assets/images/deploy-line-on-rails/SS_2024-09-28T16.00.14.png)

EC2 を選択して、

![EC2 の検索](/assets/images/deploy-line-on-rails/SS_2024-09-28T16.00.39.png)

EC2 の管理画面を表示します。

![EC2 の管理画面](/assets/images/deploy-line-on-rails/SS_2024-09-28T16.05.04.png)

画面上部のリージョンメニューから「東京」を選んで、

![東京リージョンを選択](/assets/images/deploy-line-on-rails/SS_2024-09-28T16.06.19.png)

インタンスを起動します。

![インスタンスの起動](/assets/images/deploy-line-on-rails/SS_2024-09-28T16.06.23.png)

起動するインスタンスを設定します。

#### 名前とタグ: everdiary-1

今後、サーバーを複数台にすることを考えて、サービス名 `everdiary` + `-1` としています。2台目以降は `everdiary-2 `, `everdiary-3`, ... とする想定です。

![名前とタグ:everdiary](/assets/images/deploy-line-on-rails/SS_2024-09-28T16.44.13.png)

#### アプリケーションおよび OS イメージ (Amazon マシンイメージ): Minimal Ubuntu 24.02 LTS Noble Arm

検索結果をスクロールして、「**Minimal Ubuntu 24.02 LTS - Noble (Arm)**」を選択します。**Armがついていないものや古いバージョンのものを間違って選ばないようにします**。なお、Macbook Air M3を使っているため Arm アーキテクチャを選択していますが、Intel CPU を利用している場合は Arm がついていないものを選んでください。

![Minimal Ubuntu 24.02 LTS - Noble (Arm)](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.01.57.png)

購読のダイアログには1時間あたりの料金が表示されますが、安心してください。**OS 自体の料金は無料です**。

**今すぐ購読** を選びます。

![OSイメージの選択完了](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.18.34.png)

#### インスタンスタイプ: ~~t4g.micro~~ → t4g.small

これはRails アプリを動作させるのみ最低限のスペックのものです。t4g.nano はメモリが 0.5 GBしかないので Rails アプリにはきびしいです。メモリ 1GB は不安ですが、もしスペックが足らなくても EC2 ならあとから簡単にスペックを上げられるのがいいですよね。

**(追記) t4g.micro ではメモリが足りませんでした。t4g.small を指定してください。**

![t4g.micro](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.28.46.png)

#### キーペア (ログイン): everdiary

新しいキーペアの作成を押して、

![新しいキーペアの作成を押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.33.41.png)

- キーペア名: everdiary
- キーペアのタイプ: ED25519
- プライベートキーファイル形式: .pem

を指定して、キーペアを作成します。

![キーペアを作成](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.34.32.png)

ダウンロードした `everdiary.pem` を、

![自動でキーペアをダウンロード](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.43.55.png)

`~/.ssh` に移動して、適切な権限に変更します。
**VSCode ではないターミナルで**、次のコマンドを実行します。

```bash
mkdir -p ~/.ssh/
mv ~/Downloads/everdiary.pem ~/.ssh/
chmod 600 ~/.ssh/everdiary.pem
```

これでキーペアの設定完了です。

![キーペアの設定完了](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.35.31.png)

#### ネットワーク設定: HTTPS・HTTPを許可

ネットワーク設定は、**インターネットからのHTTPSトラフィックを許可** と **インターネットからのHTTPトラフィックを許可** にチェックを入れればOK。

![HTTPSとHTTPをチェック](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.46.17.png)

#### ストレージを設定: 8GiB

ストレージはとりあえずデフォルトの 8 GiB、gp3 にします。

![ストレージは8GiB、gp3](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.53.11.png)

[簡単にサイズアップできるようなので](https://dev.classmethod.jp/articles/cahange-ebs-volume/)、しばらく運用してみて適切なサイズに変更する想定です。

#### インスタンスを起動

インスタンスを設定できたので、画面右の **インスタンスを起動ボタン** を押して、

![インスタンスを起動ボタンを押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.55.02.png)

インスタンスを起動します。

![インタンスを起動](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.58.40.png)

#### Elastic IP アドレスの割当

このままだと再起動するたびパブリック IP アドレスが変わるため、Elastic IP アドレスを割り当てます。

画面左の Elastic IP を選んで、

![Elastic IP](/assets/images/deploy-line-on-rails/SS_2024-09-28T18.12.43.png)

Elastic IP アドレス一覧画面の **Elastic IP アドレスを割り当てるボタン** を押します。

Elastic IP アドレスを割り当てる画面の設定が、

- パブリック IPv4 アドレスプール: Amazon の IpV4 アドレスプール
- ネットワークボーダーグループ: ap-northeast-1

になっていることを確認して、**割り当てボタン** を押して、

![割り当てボタンを押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T18.19.11.png)

**このElastic IP アドレスを関連付けるボタン** を押して、

![このElastic IP アドレスを関連付けるボタンを押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T18.22.10.png)

Elastic IP アドレスの関連付け画面で

- リソースタイプ: インスタンス
- インスタンス: さきほど起動したインスタンスのID

を指定して、 **関連付けるボタン** を押します。

![関連付けるボタンを押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T18.23.17.png)

これでパブリック IP アドレスを固定でき、インスタンスを再起動しても変わりません。

このあと使うので、パブリック IP アドレスをメモしておきます (ここでは 13.112.62.67 です)。

### ドメインの用意

Everdiary のドメインは、私が所有している `smalruby.app` ドメインのサブドメイン `everdiary.smalruby.app` を設定して利用することにします。

詳細な手順は省略しますが、お名前.comでドメインを購入・管理していますので、

- [サブドメインって何？ドメインとの違いやどんな時に使うのかを解説します](https://www.onamae.com/column/domain/49/?btn_id=webgakuen_article_domain_49&banner_id=1104_comnetwork_2&waad=1Jg86Y8V&network=google_x&placement=&keyword=&device=&gad_source=1&gclid=CjwKCAjw0t63BhAUEiwA5xP54VCFRz0GjGWQ2JR4cq1ZBlsaEcoMeMKlA79eUnLwEZQv7COBO7Bb-RoCKYoQAvD_BwE)
- [お名前\.comのネームサーバー（DNS）にサブドメインを追加する方法](https://www.flagsystem.co.jp/news/archives/35)

などを参考にして、次のAレコードを追加して、サブドメインを設定しました。

- ホスト名: everdiary
- TYPE: A
- TTL: 3600
  - (TTLの値はなにが正解なのだろうか...?)
- VALUE: 13.112.62.67
  - インスタンスに割り当てたパブリック IP アドレス
- 状態: 有効

![everdiaryサブドメインのAレコード](/assets/images/deploy-line-on-rails/SS_2024-09-28T19.06.22.png)

反映までに最大72時間かかるようなので、 everdiary.smalruby.app サブドメインがインターネットに反映させるまで気長に待ちます (私の場合は 10分ほどで反映されましさせれました)。

なお、ターミナルで `dig everdiary.smalruby.app` を実行して反映状況を確認できます。digについては [DIGを使用したDNSサーバの確認方法について](https://www.secuavail.com/kb/windows-linux/linux-dig-dns/) が詳しかったです。

### Docker のアクセストークン

Docker Desktop のメニューの右上から Account Settings (アカウント設定) を選択して、

![Account Settings](/assets/images/deploy-line-on-rails/SS_2024-09-28T19.15.16.png)

ブラウザに表示された Personal access tokens の管理画面に移動して、

![Personal access tokens の管理画面に移動](/assets/images/deploy-line-on-rails/SS_2024-09-28T19.31.18.png)

**Generate new tokenボタン** を押して、

![Generate new tokenボタンを押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T19.33.27.png)

Create access token 画面で、

- Access token description: everdiary
  - サービス名を指定します
- Access permission: Read, Write, Delete
  - フルアクセス。ReadとWriteだけでいいような気もしますが、念の為。

を指定して、 **Generateボタン** を押して、

![Generateボタンを押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T19.34.17.png)

アクセストークンを生成します。この画面でしかアクセストークンは確認できないので注意してください。

`dckr_` から始まるアクセストークンをコピーして、

![アクセストークンのコピー](/assets/images/deploy-line-on-rails/SS_2024-09-28T19.41.34.png)

`.env` に追加します。

```shell
# LINE ログイン
LINE_KEY="xxx..."
LINE_SECRET="xxx..."

# LINE Messaging API
LINE_CHANNEL_SECRET="xxx..."
LINE_CHANNEL_TOKEN="xxx..."

# Kamal
KAMAL_REGISTRY_PASSWORD="dckr_..." # ← これを追記
```

### SSH の設定

#### キーペアをコンテナから見られるようにする

`.devcontainer/compose.yaml` を修正して、インスタンスに接続するためのキーペアをコンテナから見えるようにします。`/Users/kouji/.ssh` は自分の環境に合わせてホームディレクトリ + `.ssh` を指定してください。

```yaml
name: "everdiary"

services:
  rails-app:
    build:
      context: ..
      dockerfile: .devcontainer/Dockerfile

    volumes:
    - ../..:/workspaces:cached
    - /Users/kouji/.ssh:/workspaces/everdiary/.ssh:cached # ← この行を追加

# (省略)
```

ファイルを修正できたら、VSCode でコンテナをリビルドします。
リビルド後、コンテナで開いた VSCode ターミナルで .ssh が見られれば OK です。

```text
$ ls -l .ssh
total xxx
-rw-r--r-- 1 vscode vscode  230 Sep 28 11:04 config
-rw------- 1 vscode vscode  387 Sep 28 08:35 everdiary.pem
```

キーペアを誤ってコミットしてしまわないように `.gitignore` の末尾に以下を追加して除外します。

```text
# (省略)

# Ignore for Kamal
/.ssh
```

#### `ssh everdiary.smalruby.app` でログイン可能にする

ついでに、インスタンスへのログインが簡単にできるように、`~/.ssh/config` ファイルを作成して、以下の内容を記載します。Kamal で問題が起きたときのバックアップですね。

```text
Host everdiary.smalruby.app
  HostName 13.112.62.67
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/everdiary.pem
  User ubuntu
```

↑のうち、`everdiary.smalruby.app`、`13.112.62.67`、`IdentityFile` は私のドメイン、インスタンスのパブリック IP アドレス、キーペアなので、それぞれを自分のものに書き換えてください。

ファイルを作成できたらログインできることを確認します。

```text
$ ssh everdiary.smalruby.app
The authenticity of host '13.112.62.67 (13.112.62.67)' can't be established.
ED25519 key fingerprint is SHA256:VdfHyRAxM+kzBrob/ap9KczvGs3oq3/Mu6Smih/wwJc.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes # ← ここで yes と入力して enter
Warning: Permanently added '13.112.62.67' (ED25519) to the list of known hosts.
Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 6.8.0-1014-aws aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-172-31-33-123:~$ exit # ← ここで exit と入力して enter
logout
Connection to 13.112.62.67 closed.
```

### データベースの設定

Everdiary のデータベース (マネージメントシステム) は MySQL です。もしデプロイする Rails アプリがデフォルトの SQLite を使っている場合は、
[Ruby on RailsでDBを途中からmysqlに変更したいときに変更する場所](https://qiita.com/leafeon00000/items/be9cbb3e4eac4fbef7a1) などを参考にして、MySQL に変更してください。

#### パスワードの設定

設定を簡単にするために MySQL のルートユーザーと Everdiary のパスワードは同じものにします。

`.env` に `MYSQL_ROOT_PASSWORD` を追加して、パスワードを記載します。パスワードの生成は `pwgen` コマンドが便利です。

```shell
# LINE ログイン
LINE_KEY="xxx..."
LINE_SECRET="xxx..."

# LINE Messaging API
LINE_CHANNEL_SECRET="xxx..."
LINE_CHANNEL_TOKEN="xxx..."

# データベース
MYSQL_ROOT_PASSWORD="xxx..." # ←これを追加

# Kamal
KAMAL_REGISTRY_PASSWORD="dckr_xxx..."
```

合わせて、 Rails アプリのデータベースの設定 `config/database.yml` も変更します。本当は Rails アプリの元々の設定 (`username: everdiary` など) をそのまま使いたかったのですが、デプロイを優先するために Kamal の都合に合わせています。

```yaml
production:
  <<: *default
  database: everdiary_production
  username: root # ←これを修正
  password: <%= ENV["MYSQL_ROOT_PASSWORD"] %> # ←これを修正
```

#### MySQL の設定ファイル

`config/mysql/production.cnf` ファイルを作成して、[DockerでRuby on Railsの環境を構築する際のmysql\.cnfのコマンド及びコード理解](https://qiita.com/zakino123/items/ba916a88f537fb765928) を参考にして以下の内容を記載します。記事との差分は `collation-server = utf8mb4_bin` です。

```text
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_bin
init-connect = SET NAMES utf8mb4
skip-character-set-client-handshake

[client]
default-character-set = utf8mb4

[mysqldump]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
```

#### データベースの初期セットアップ SQL

`db/production.sql` ファイルを作成して、データベースを作成するための SQL を記載します。

```sql
CREATE DATABASE everdiary_production;
```

### kamal setup

これで準備が整いました。Kamal を設定して、Everdiary を EC2 にデプロイします。

#### config/deploy.yml

`config/deploy.yml` を修正します。コメントを参考にして、パブリック IP アドレス、ドメイン名などは自分の情報に合わせてください。

```yaml
service: everdiary # サービス名

image: takaokouji/everdiary # Dockerのアカウント名/サービス名

servers:
  web:
    hosts:
      - 13.112.62.67 # パブリック IP アドレス
    cmd: ./bin/rails server
    env:
      clear:
        DB_HOST: everdiary-db # サービス名-db
      secret:
        - LINE_KEY
        - LINE_SECRET
        - LINE_CHANNEL_SECRET
        - LINE_CHANNEL_TOKEN
        - MYSQL_ROOT_PASSWORD
        - RAILS_MASTER_KEY

proxy:
  ssl: true
  host: everdiary.smalruby.app # ドメイン名
  app_port: 3000

registry:
  username: takaokouji # Dockerのアカウント名
  password:
    - KAMAL_REGISTRY_PASSWORD

builder:
  arch: arm64

ssh:
  user: ubuntu

accessories:
  db:
    image: mysql/mysql-server:8.0
    roles:
      - web
    port: 3306
    env:
      clear:
        MYSQL_ALLOW_EMPTY_PASSWORD: 'true'
        MYSQL_ROOT_HOST: '%'
      secret:
        - MYSQL_ROOT_PASSWORD
    files:
      - config/mysql/production.cnf:/etc/mysql/my.cnf
      - db/production.sql:/docker-entrypoint-initdb.d/setup.sql
    directories:
      - mysql-data:/var/lib/mysql
```

#### .kamal/secrets

続いて `.kamal/secrets` を修正します。`LINE_KEY` などの項目は `.env` とほぼ同じで、値は `$LINE_KEY` のように `$項目名` とします。

```text
# LINE ログイン
LINE_KEY=$LINE_KEY
LINE_SECRET=$LINE_SECRET

# LINE Messaging API
LINE_CHANNEL_SECRET=$LINE_CHANNEL_SECRET
LINE_CHANNEL_TOKEN=$LINE_CHANNEL_TOKEN

# データベース
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD

# Kamal
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD

RAILS_MASTER_KEY=$(cat config/master.key)
```

#### .kamal/hooks/docker-setup

EC2 上の ubuntu ユーザーの権限が不足しているため、 hook でなんとかします。

`.kamal/hooks/docker-setup.sample` を `.kamal/hooks/docker-setup` にリネームして、以下の内容に書き換えます。

```ruby
#!/usr/bin/env ruby

hosts = ENV["KAMAL_HOSTS"].split(",")

user = "ubuntu"

hosts.each do |ip|
  destination = "#{user}@#{ip}"
  puts "Add \"#{user}\" to the docker group on #{destination}"
  `ssh #{destination} sudo usermod -aG docker #{user}`
end
```

#### tailwindcss gem を production から除外

assets:precompile に失敗するため、`Gemfile` を修正して tailwindcss gem を production から除外します。

```ruby
gem "tailwindcss-rails", "~> 2.7", :groups => [:development, :test] # この行だけを修正
```

#### kamal setup

それではお待ちかねの kamal setup です。

**VSCode のターミナル上で** 次のコマンドを実行します。なお、現時点の Kamal は ssh-agent が起動していないと動作しません (Net::SSH に ssh_agent: false オプションを渡せるようにする必要があり、簡単には直せそうになかったです)。

```bash
eval `ssh-agent -s`
ssh-add .ssh/everdiary.pem
set -a; source .env; set +a;
bundle exec kamal setup
```

最後に `Finished all in xxx seconds` と表示されていれば成功です。おめでとうございます！

{% raw %}
```text
$ bundle exec kamal setup
  INFO [62150540] Running /usr/bin/env mkdir -p .kamal on 13.112.62.67
  INFO [62150540] Finished in 0.534 seconds with exit status 0 (successful).
Acquiring the deploy lock...
Ensure Docker is installed...
  INFO [3737ab0b] Running docker -v on 13.112.62.67
  INFO [3737ab0b] Finished in 0.086 seconds with exit status 0 (successful).
(省略)
  INFO [44332814] Running docker image ls --filter label=service=everdiary --format '{{.ID}} {{.Repository}}:{{.Tag}}' | grep -v -w "$(docker container ls -a --format '{{.Image}}\|' --filter label=service=everdiary | tr -d '\n')takaokouji/everdiary:latest\|takaokouji/everdiary:<none>" | while read image tag; do docker rmi $tag; done on 13.112.62.67
  INFO [44332814] Finished in 0.117 seconds with exit status 0 (successful).
  Finished all in 107.0 seconds
Releasing the deploy lock...
  Finished all in 123.1 seconds ← これがでれば成功！
```
{% endraw %}

また、残念ながら`ERROR` と表示された場合はデプロイに失敗しています。エラーメッセージとにらめっこしながら解決していきます。

デプロイの失敗例:

```text
(省略)
Releasing the deploy lock...
  Finished all in 4.2 seconds
  ERROR (SSHKit::Command::Failed): Exception while executing on host 13.112.62.67: docker exit status: 125
docker stdout: Nothing written
docker stderr: docker: Error response from daemon: Conflict. The container name "/everdiary-db" is already in use by container "ff8dd5249a24e48baeb4273473ac97d76cc6320c09a3ce7f99d309bcb093da34". You have to remove (or rename) that container to be able to reuse that name.
See 'docker run --help'.
```

#### LINE ログインのコールバック URL の変更

[LINE Developers コンソール](https://developers.line.biz/console/) にアクセスして、LINE ログインのコールバック URL を `https://everdiary.smalruby.app/my_line_users/auth/line/callback` に変更します。

![LINE ログインのコールバック URL](/assets/images/deploy-line-on-rails/SS_2024-09-29T13.04.44.png)

#### 動作確認 → デプロイ完了

それでは <https://everdiary.smalruby.app/> にアクセスします。

- Everdiary のサインアップ
- LINE 連携
- 日記の登録 → LINE メッセージ送信

これでデプロイ完了です！
お疲れ様でした。

### kamal deploy

Rails アプリを修正後は、

```bash
bundle exec kamal deploy
```

で更新できます。簡単ですね。

### やり直したいときは kamal remove

デプロイをやり直したいこともあるでしょう。
その場合は、

```bash
bundle exec kamal accessory exec db "chmod 777 -R /var/lib/mysql"
bundle exec kamal remove
```

でデプロイしたものをすべて削除できます。ただし、DBも消えるため注意してください。

/var/lib/mysql の権限を変更しているのは、次のエラー対策です。こんな感じのエラーがバーっと表示されるので、原因を調べるのはいったんやめて、回避することにしました。

```text
rm stderr: rm: cannot remove 'everdiary-db/mysql-data/sys/sys_config.ibd': Permission denied
rm: cannot remove 'everdiary-db/mysql-data/performance_schema/events_transacti_137.sdi': Permission denied
```

### おわりに

途中、何度も諦めかけましたが、デプロイできました。リリース直後なので Kamal 自体を疑ってしまって、自分の設定ミスに気が付かなかったりね。

とはいえ、かなり Kamal について詳しくなったので Happy です！

### 付録

作業開始からデプロイ完了までの試行錯誤の記録を付録として残しておきます。

#### 付録1: devcontiner で Kamal を使おうとして詰んだときの記録

**devcontiner で Kamal を使おうとして、最終的に docker コマンドが使えないために詰んだのですが、記録として残しておきます。**

なお、その後の調査で **devcontiner でも問題なく Kamal が使えることがわかりました** 。

`config/deploy.yml`

```yaml
# Name of your application. Used to uniquely configure containers.
service: everdiary

# Name of the container image.
image: takaokouji/everdiary

# Deploy to these servers.
servers:
  web:
    - 13.112.62.67
  # job:
  #   hosts:
  #     - 192.168.0.1
  #   cmd: bin/jobs

# Enable SSL auto certification via Let's Encrypt (and allow for multiple apps on one server).
# Set ssl: false if using something like Cloudflare to terminate SSL (but keep host!).
proxy:
  ssl: true
  host: everdiary.smalruby.app

# Credentials for your image host.
registry:
  # Specify the registry server, if you're not using Docker Hub
  # server: registry.digitalocean.com / ghcr.io / ...
  username: takaokouji

  # Always use an access token rather than real password (pulled from .kamal/secrets).
  password:
    - KAMAL_REGISTRY_PASSWORD

# Configure builder setup.
builder:
  arch: arm64

# Inject ENV variables into containers (secrets come from .kamal/secrets).
#
# env:
#   clear:
#     DB_HOST: 192.168.0.2
#   secret:
#     - RAILS_MASTER_KEY

# Aliases are triggered with "bin/kamal <alias>". You can overwrite arguments on invocation:
# "bin/kamal logs -r job" will tail logs from the first server in the job section.
#
# aliases:
#   shell: app exec --interactive --reuse "bash"

# Use a different ssh user than root
#
ssh:
  user: ubuntu
  keys: [ "~/.ssh/everdiary.pem" ]

# Use a persistent storage volume.
#
# volumes:
#   - "app_storage:/app/storage"

# Bridge fingerprinted assets, like JS and CSS, between versions to avoid
# hitting 404 on in-flight requests. Combines all files from new and old
# version inside the asset_path.
#
# asset_path: /app/public/assets

# Configure rolling deploys by setting a wait time between batches of restarts.
#
# boot:
#   limit: 10 # Can also specify as a percentage of total hosts, such as "25%"
#   wait: 2

# Use accessory services (secrets come from .kamal/secrets).
#
accessories:
  db:
    image: mysql/mysql-server:8.0
    host: 13.112.62.67
    port: 3306
    env:
      clear:
        MYSQL_ALLOW_EMPTY_PASSWORD: 'true'
        MYSQL_ROOT_HOST: '%'
      secret:
        - MYSQL_ROOT_PASSWORD
    files:
      - config/mysql/production.cnf:/etc/mysql/my.cnf
      - db/production.sql:/docker-entrypoint-initdb.d/setup.sql
    directories:
      - mysql-data:/var/lib/mysql
#   redis:
#     image: redis:7.0
#     host: 192.168.0.2
#     port: 6379
#     directories:
#       - data:/data
```

`.kamal/secrets`

```text
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY=$(cat config/master.key)
MYSQL_ROOT_PASSWORD=$EVERDIARY_DATABASE_PASSWORD
```

```bash
set -a; source .env; set +a;
kamal setup --verbose
```

ここでエラーが発生。

```
$ kamal setup --verbose
  INFO [a7344c69] Running /usr/bin/env mkdir -p .kamal on 13.112.62.67
 DEBUG [a7344c69] Command: /usr/bin/env mkdir -p .kamal
  Finished all in 0.2 seconds
  ERROR (FrozenError): Exception while executing on host 13.112.62.67: can't modify frozen String: ""
```

[can't modify frozen String: "" when ssh\-agent is misconfigured \#867](https://github.com/net-ssh/net-ssh/issues/867) と同じエラー。Kamal には SSH Agentをオフにする設定はないため、どうしたものか考えていたのですが、よくよく考えてみると、コンテナ上で Kamal を実行していたため、SSH のキーペアが参照できなかっただけなことに気が付きました。

**VSCode ではないターミナルで**、次のコマンドを実行してキーペアをコンテナから見えるようにします。

```
cd path/to/everdiary
mkdir .ssh
cp ~/.ssh/everdiary.pem .ssh/
```

`config/deploy.yml` の該当箇所を修正。

```yaml
ssh:
  user: ubuntu
  keys: [ ".ssh/everdiary.pem" ] # ← ここを修正

```

これで Kamal を再実行...。変化なし。まだ NG。

ダメ元で **VSCode ではないターミナルで**、次のコマンドを実行してキーペアを ssh-agent に登録してみる。

```bash
eval `ssh-agent -s`
ssh-add ~/.ssh/everdiary.pem
# (以下、実行結果)
# Identity added: /Users/kouji/.ssh/everdiary.pem (/Users/kouji/.ssh/everdiary.pem)
```

これで Kamal を再実行...。変化なし。まだ NG。

さらに、ダメ元で **VSCode のターミナルで**、次のコマンドを実行してキーペアを ssh-agent に登録してみる。

```bash
eval `ssh-agent -s`
ssh-add .ssh/everdiary.pem
# (以下、実行結果)
# Identity added: .ssh/everdiary.pem (.ssh/everdiary.pem)
```

これで Kamal を再実行...。おぉ、SSH で接続できている。なるほど、こうするのが正解だったのですね。

```text
$ kamal setup
  INFO [53df6f44] Running /usr/bin/env mkdir -p .kamal on 13.112.62.67
  INFO [53df6f44] Finished in 0.493 seconds with exit status 0 (successful).
Acquiring the deploy lock...
Ensure Docker is installed...
  INFO [d7080393] Running docker -v on 13.112.62.67
  INFO [d7080393] Finished in 0.080 seconds with exit status 0 (successful).
  INFO [18b24b8d] Running docker login -u [REDACTED] -p [REDACTED] on 13.112.62.67
  INFO [18b24b8d] Finished in 1.617 seconds with exit status 0 (successful).
  INFO [312ae3ee] Running docker network create kamal on 13.112.62.67
Releasing the deploy lock...
  Finished all in 2.5 seconds
  ERROR (SSHKit::Command::Failed): Exception while executing on host 13.112.62.67: docker exit status: 1
docker stdout: Nothing written
docker stderr: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Head "http://%2Fvar%2Frun%2Fdocker.sock/_ping": dial unix /var/run/docker.sock: connect: permission denied
```

とはいえ、別のエラーが発生しています。EC2 上の ubuntu ユーザーの権限不足です。
これは hook でなんとなできそう。

`.kamal/hooks/docker-setup.sample` を `.kamal/hooks/docker-setup` にリネームして、以下の内容に書き換えます。

```ruby
#!/usr/bin/env ruby

hosts = ENV["KAMAL_HOSTS"].split(",")

user = "ubuntu"

hosts.each do |ip|
  destination = "#{user}@#{ip}"
  puts "Add \"#{user}\" to the docker group on #{destination}"
  `ssh #{destination} sudo usermod -aG docker #{user}`
end
```

これで Kamal を再実行...。少し進みましたが、またエラーです。

```
$ kamal setup
  INFO [2d0a6667] Running /usr/bin/env mkdir -p .kamal on 13.112.62.67
  INFO [2d0a6667] Finished in 0.574 seconds with exit status 0 (successful).
Acquiring the deploy lock...
Ensure Docker is installed...
  INFO [73487f27] Running docker -v on 13.112.62.67
  INFO [73487f27] Finished in 0.218 seconds with exit status 0 (successful).
Running the docker-setup hook...
  INFO [ff56840e] Running /usr/bin/env .kamal/hooks/docker-setup as vscode@localhost
  INFO [ff56840e] Finished in 0.492 seconds with exit status 0 (successful).
  INFO [79a2108c] Running docker login -u [REDACTED] -p [REDACTED] on 13.112.62.67
  INFO [79a2108c] Finished in 1.639 seconds with exit status 0 (successful).
  INFO [4110b3e7] Running docker network create kamal on 13.112.62.67
  INFO [d2c33dd2] Running /usr/bin/env mkdir -p $PWD/everdiary-db/mysql-data on 13.112.62.67
  INFO [d2c33dd2] Finished in 0.061 seconds with exit status 0 (successful).
  INFO [a3483285] Running /usr/bin/env mkdir -p everdiary-db/etc/mysql on 13.112.62.67
  INFO [a3483285] Finished in 0.059 seconds with exit status 0 (successful).
  INFO Uploading /workspaces/everdiary/config/mysql/production.cnf 100.0%
  INFO [5aa29f1f] Running /usr/bin/env chmod 755 everdiary-db/etc/mysql/my.cnf on 13.112.62.67
  INFO [5aa29f1f] Finished in 0.063 seconds with exit status 0 (successful).
  INFO [6ac6c53c] Running /usr/bin/env mkdir -p everdiary-db/docker-entrypoint-initdb.d on 13.112.62.67
  INFO [6ac6c53c] Finished in 0.060 seconds with exit status 0 (successful).
  INFO Uploading /workspaces/everdiary/db/production.sql 100.0%
  INFO [6d832577] Running /usr/bin/env chmod 755 everdiary-db/docker-entrypoint-initdb.d/setup.sql on 13.112.62.67
  INFO [6d832577] Finished in 0.059 seconds with exit status 0 (successful).
  INFO [67dfe5a6] Running /usr/bin/env mkdir -p .kamal/apps/everdiary/env/accessories on 13.112.62.67
  INFO [67dfe5a6] Finished in 0.058 seconds with exit status 0 (successful).
  INFO Uploading .kamal/apps/everdiary/env/accessories/db.env 100.0%
  INFO [dce0bb3f] Running docker run --name everdiary-db --detach --restart unless-stopped --network kamal --log-opt max-size="10m" --publish 3306:3306 --env MYSQL_ALLOW_EMPTY_PASSWORD="true" --env MYSQL_ROOT_HOST="%" --env-file .kamal/apps/everdiary/env/accessories/db.env --volume $PWD/everdiary-db/etc/mysql/my.cnf:/etc/mysql/my.cnf --volume $PWD/everdiary-db/docker-entrypoint-initdb.d/setup.sql:/docker-entrypoint-initdb.d/setup.sql --volume $PWD/everdiary-db/mysql-data:/var/lib/mysql --label service="everdiary-db" mysql/mysql-server:8.0 on 13.112.62.67
Releasing the deploy lock...
  Finished all in 4.2 seconds
  ERROR (SSHKit::Command::Failed): Exception while executing on host 13.112.62.67: docker exit status: 125
docker stdout: Nothing written
docker stderr: docker: Error response from daemon: Conflict. The container name "/everdiary-db" is already in use by container "ff8dd5249a24e48baeb4273473ac97d76cc6320c09a3ce7f99d309bcb093da34". You have to remove (or rename) that container to be able to reuse that name.
See 'docker run --help'.
```

エラーの内容は everdiary-db コンテナはすでに起動しています、というもの。何度も setup を実行しているのが問題なのかもしれません。

EC2 のインスタンスにログインして確認すると確かに everdiary-db が起動していました。

```text
ubuntu@ip-172-31-33-123:~$ docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS                    PORTS                                                        NAMES
ff8dd5249a24   mysql/mysql-server:8.0   "/entrypoint.sh mysq…"   12 minutes ago   Up 11 minutes (healthy)   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060-33061/tcp   everdiary-db
```

ここまで何度も setup を実行してしまったので、いったん remove してからやり直してみる。

{% raw %}
```text
vscode ➜ /workspaces/everdiary (main) $ kamal remove
This will remove all containers and images. Are you sure? [y, N] (N) y
  INFO [9fbb8e89] Running /usr/bin/env mkdir -p .kamal on 13.112.62.67
  INFO [9fbb8e89] Finished in 0.373 seconds with exit status 0 (successful).
Acquiring the deploy lock...
  INFO [951dc097] Running /usr/bin/env sh -c 'docker ps --latest --format '\''{{.Names}}'\'' --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=takaokouji/everdiary:latest --format '\''{{.ID}}'\'') ; docker ps --latest --format '\''{{.Names}}'\'' --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting' | head -1 | while read line; do echo ${line#everdiary-web-}; done on 13.112.62.67
  INFO [951dc097] Finished in 0.105 seconds with exit status 0 (successful).
  INFO [fa9c9fb6] Running docker container ls --all --filter name=^everdiary-web-$ --quiet on 13.112.62.67
  INFO [fa9c9fb6] Finished in 0.077 seconds with exit status 0 (successful).
  INFO [e8ddf310] Running /usr/bin/env sh -c 'docker ps --latest --quiet --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=takaokouji/everdiary:latest --format '\''{{.ID}}'\'') ; docker ps --latest --quiet --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting' | head -1 | xargs docker stop on 13.112.62.67
  INFO [e8ddf310] Finished in 0.114 seconds with exit status 123 (failed).
  INFO [07b4fbf2] Running docker container prune --force --filter label=service=everdiary --filter label=role=web on 13.112.62.67
  INFO [07b4fbf2] Finished in 0.070 seconds with exit status 0 (successful).
  INFO [fc15c79f] Running docker image prune --all --force --filter label=service=everdiary on 13.112.62.67
  INFO [fc15c79f] Finished in 0.069 seconds with exit status 0 (successful).
  INFO [726f4be5] Running /usr/bin/env rm -r .kamal/apps/everdiary on 13.112.62.67
  INFO [726f4be5] Finished in 0.070 seconds with exit status 0 (successful).
  INFO [4bfeb6c4] Running /usr/bin/env ls .kamal/apps | wc -l on 13.112.62.67
  INFO [4bfeb6c4] Finished in 0.058 seconds with exit status 0 (successful).
  INFO [819ce503] Running docker container stop kamal-proxy on 13.112.62.67
  INFO [819ce503] Finished in 0.083 seconds with exit status 1 (failed).
  INFO [47ba2e83] Running docker container prune --force --filter label=org.opencontainers.image.title=kamal-proxy on 13.112.62.67
  INFO [47ba2e83] Finished in 0.074 seconds with exit status 0 (successful).
  INFO [700b20af] Running docker image prune --all --force --filter label=org.opencontainers.image.title=kamal-proxy on 13.112.62.67
  INFO [700b20af] Finished in 0.078 seconds with exit status 0 (successful).
  INFO [6e2c42fc] Running /usr/bin/env rm -r .kamal/proxy on 13.112.62.67
  INFO [6e2c42fc] Finished in 0.063 seconds with exit status 1 (failed).
This will remove all containers, images and data directories for all. Are you sure? [y, N] (N) y
  INFO [6da2fe6c] Running docker container stop everdiary-db on 13.112.62.67
  INFO [6da2fe6c] Finished in 0.787 seconds with exit status 0 (successful).
  INFO [d0104799] Running docker container prune --force --filter label=service=everdiary-db on 13.112.62.67
  INFO [d0104799] Finished in 0.086 seconds with exit status 0 (successful).
  INFO [53531d17] Running docker image rm --force mysql/mysql-server:8.0 on 13.112.62.67
  INFO [53531d17] Finished in 0.499 seconds with exit status 0 (successful).
  INFO [4ea81781] Running /usr/bin/env rm -rf everdiary-db on 13.112.62.67
Releasing the deploy lock...
  ERROR (SSHKit::Command::Failed): Exception while executing on host 13.112.62.67: rm exit status: 1
rm stdout: Nothing written
rm stderr: rm: cannot remove 'everdiary-db/mysql-data/sys/sys_config.ibd': Permission denied
rm: cannot remove 'everdiary-db/mysql-data/performance_schema/events_transacti_137.sdi': Permission denied
rm: cannot remove 'everdiary-db/mysql-data/performance_schema/session_connect__150.sdi': Permission denied
rm: cannot remove 'everdiary-db/mysql-data/performance_schema/events_statement_120.sdi': Permission denied
(省略)
rm: cannot remove 'everdiary-db/mysql-data/mysql/general_log_213.sdi': Permission denied
rm: cannot remove 'everdiary-db/mysql-data/mysql/slow_log_214.sdi': Permission denied
rm: cannot remove 'everdiary-db/mysql-data/mysql/slow_log.CSM': Permission denied
```
{% endraw %}

kamal remove でもエラーが発生。MySQL のデータ削除ができないように見えます。
問題のファイルの権限を確認するとたしかに ubuntu ユーザーには削除権限がありません。
この対応は難しそうなので、EC2 にログインして、手動で権限を付与して回避します。

```bash
sudo chmod 777 -R everdiary-db
```

再度、kamal remove。今度は成功。

{% raw %}
```text
$ kamal remove
This will remove all containers and images. Are you sure? [y, N] (N) y
  INFO [d3032c7d] Running /usr/bin/env mkdir -p .kamal on 13.112.62.67
  INFO [d3032c7d] Finished in 0.570 seconds with exit status 0 (successful).
Acquiring the deploy lock...
  INFO [c6677754] Running /usr/bin/env sh -c 'docker ps --latest --format '\''{{.Names}}'\'' --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=takaokouji/everdiary:latest --format '\''{{.ID}}'\'') ; docker ps --latest --format '\''{{.Names}}'\'' --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting' | head -1 | while read line; do echo ${line#everdiary-web-}; done on 13.112.62.67
  INFO [c6677754] Finished in 0.099 seconds with exit status 0 (successful).
  INFO [6fb1b8fe] Running docker container ls --all --filter name=^everdiary-web-$ --quiet on 13.112.62.67
  INFO [6fb1b8fe] Finished in 0.066 seconds with exit status 0 (successful).
  INFO [a218d693] Running /usr/bin/env sh -c 'docker ps --latest --quiet --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting --filter ancestor=$(docker image ls --filter reference=takaokouji/everdiary:latest --format '\''{{.ID}}'\'') ; docker ps --latest --quiet --filter label=service=everdiary --filter label=role=web --filter status=running --filter status=restarting' | head -1 | xargs docker stop on 13.112.62.67
  INFO [a218d693] Finished in 0.112 seconds with exit status 123 (failed).
  INFO [36d45245] Running docker container prune --force --filter label=service=everdiary --filter label=role=web on 13.112.62.67
  INFO [36d45245] Finished in 0.069 seconds with exit status 0 (successful).
  INFO [899bd8b9] Running docker image prune --all --force --filter label=service=everdiary on 13.112.62.67
  INFO [899bd8b9] Finished in 0.065 seconds with exit status 0 (successful).
  INFO [136b620d] Running /usr/bin/env rm -r .kamal/apps/everdiary on 13.112.62.67
  INFO [136b620d] Finished in 0.057 seconds with exit status 1 (failed).
  INFO [3dae9b8f] Running /usr/bin/env ls .kamal/apps | wc -l on 13.112.62.67
  INFO [3dae9b8f] Finished in 0.061 seconds with exit status 0 (successful).
  INFO [9baddb4f] Running docker container stop kamal-proxy on 13.112.62.67
  INFO [9baddb4f] Finished in 0.067 seconds with exit status 1 (failed).
  INFO [300d95f9] Running docker container prune --force --filter label=org.opencontainers.image.title=kamal-proxy on 13.112.62.67
  INFO [300d95f9] Finished in 0.065 seconds with exit status 0 (successful).
  INFO [1e48b436] Running docker image prune --all --force --filter label=org.opencontainers.image.title=kamal-proxy on 13.112.62.67
  INFO [1e48b436] Finished in 0.063 seconds with exit status 0 (successful).
  INFO [2869a79d] Running /usr/bin/env rm -r .kamal/proxy on 13.112.62.67
  INFO [2869a79d] Finished in 0.054 seconds with exit status 1 (failed).
This will remove all containers, images and data directories for all. Are you sure? [y, N] (N) y
  INFO [030bbaf9] Running docker container stop everdiary-db on 13.112.62.67
  INFO [030bbaf9] Finished in 0.066 seconds with exit status 1 (failed).
  INFO [2d5faec9] Running docker container prune --force --filter label=service=everdiary-db on 13.112.62.67
  INFO [2d5faec9] Finished in 0.071 seconds with exit status 0 (successful).
  INFO [f7dc5330] Running docker image rm --force mysql/mysql-server:8.0 on 13.112.62.67
  INFO [f7dc5330] Finished in 0.067 seconds with exit status 0 (successful).
  INFO [9efce15e] Running /usr/bin/env rm -rf everdiary-db on 13.112.62.67
  INFO [9efce15e] Finished in 0.057 seconds with exit status 0 (successful).
  INFO [811c5faa] Running docker logout on 13.112.62.67
  INFO [811c5faa] Finished in 0.063 seconds with exit status 0 (successful).
Releasing the deploy lock...
```
{% endraw %}

そして、もう一度 kamal setup。

```text
$ kamal setup
  INFO [e03e00e3] Running /usr/bin/env mkdir -p .kamal on 13.112.62.67
  INFO [e03e00e3] Finished in 0.636 seconds with exit status 0 (successful).
Acquiring the deploy lock...
Ensure Docker is installed...
  INFO [93f28d54] Running docker -v on 13.112.62.67
  INFO [93f28d54] Finished in 0.100 seconds with exit status 0 (successful).
Running the docker-setup hook...
  INFO [9043f852] Running /usr/bin/env .kamal/hooks/docker-setup as vscode@localhost
  INFO [9043f852] Finished in 0.530 seconds with exit status 0 (successful).
  INFO [98a17fe4] Running docker login -u [REDACTED] -p [REDACTED] on 13.112.62.67
  INFO [98a17fe4] Finished in 1.648 seconds with exit status 0 (successful).
  INFO [5488cebc] Running docker network create kamal on 13.112.62.67
  INFO [08ba1735] Running /usr/bin/env mkdir -p $PWD/everdiary-db/mysql-data on 13.112.62.67
  INFO [08ba1735] Finished in 0.108 seconds with exit status 0 (successful).
  INFO [21a3af17] Running /usr/bin/env mkdir -p everdiary-db/etc/mysql on 13.112.62.67
  INFO [21a3af17] Finished in 0.100 seconds with exit status 0 (successful).
  INFO Uploading /workspaces/everdiary/config/mysql/production.cnf 100.0%
  INFO [8c038dd0] Running /usr/bin/env chmod 755 everdiary-db/etc/mysql/my.cnf on 13.112.62.67
  INFO [8c038dd0] Finished in 0.086 seconds with exit status 0 (successful).
  INFO [6e44e9d8] Running /usr/bin/env mkdir -p everdiary-db/docker-entrypoint-initdb.d on 13.112.62.67
  INFO [6e44e9d8] Finished in 0.083 seconds with exit status 0 (successful).
  INFO Uploading /workspaces/everdiary/db/production.sql 100.0%
  INFO [fa756691] Running /usr/bin/env chmod 755 everdiary-db/docker-entrypoint-initdb.d/setup.sql on 13.112.62.67
  INFO [fa756691] Finished in 0.092 seconds with exit status 0 (successful).
  INFO [3c629bad] Running /usr/bin/env mkdir -p .kamal/apps/everdiary/env/accessories on 13.112.62.67
  INFO [3c629bad] Finished in 0.074 seconds with exit status 0 (successful).
  INFO Uploading .kamal/apps/everdiary/env/accessories/db.env 100.0%
  INFO [cfe05d73] Running docker run --name everdiary-db --detach --restart unless-stopped --network kamal --log-opt max-size="10m" --publish 3306:3306 --env MYSQL_ALLOW_EMPTY_PASSWORD="true" --env MYSQL_ROOT_HOST="%" --env-file .kamal/apps/everdiary/env/accessories/db.env --volume $PWD/everdiary-db/etc/mysql/my.cnf:/etc/mysql/my.cnf --volume $PWD/everdiary-db/docker-entrypoint-initdb.d/setup.sql:/docker-entrypoint-initdb.d/setup.sql --volume $PWD/everdiary-db/mysql-data:/var/lib/mysql --label service="everdiary-db" mysql/mysql-server:8.0 on 13.112.62.67
  INFO [cfe05d73] Finished in 11.848 seconds with exit status 0 (successful).
Log into image registry...
  INFO [8abd065f] Running docker login -u [REDACTED] -p [REDACTED] as vscode@localhost
  Finished all in 0.0 seconds
Releasing the deploy lock...
  Finished all in 16.5 seconds
  ERROR (SSHKit::Command::Failed): docker exit status: 32512
docker stdout: Nothing written
docker stderr: sh: 1: docker: not found
```

今度は setup まではバッチリ。が、エラー...。手元に docker コマンドがないというエラー。たしかに。
devcontainer 上では docker コマンドを実行できないないため、ここで積んだ。

結論、 **devcontainer では Kamal は無理**。

諦めて **VSCode ではないターミナルで** やり直すことにしました。

**(追記)のちにコンテナ上で docker build できることがわかりました**

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
