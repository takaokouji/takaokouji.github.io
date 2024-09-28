---
layout: single
title: "LINEログイン・メッセージ送信可能なRailsアプリをデプロイする"
description: "LINE ログイン、LINE Messaging API によるメッセージ送信が可能な Rails アプリを Kamel を使って EC2 にデプロイします。HTTPS 通信では無料の Let's Encrypt のSSL証明書を利用します。"
lang: ja_JP
categories: output
tags: ruby rails line kamel ec2
toc: true
last_modified_at: 2024-09-28T18:00:00+0900
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

しかしながら、実際に試す段になっ他タイミングで [Kamal のバージョン 2.0.0](https://github.com/basecamp/kamal/releases/tag/v2.0.0) が公開されました。変更点は[こちら](https://kamal-deploy.org/docs/upgrading/overview/)が参考になります。

新バージョンのリリース自体はウェルカムなのですが、調べた情報がそのままでは使えなくなってしまいました。でもそれも人柱になるチャンスだと思って、Kamal 2.0 でのデプロイに挑戦していきます。

### 事前準備

Kamal でのデプロイに先立って、用意しておくアカウントや情報がいくつかあります。

- Docker のアカウント
- AWS のアカウント

WIP

### Kamalのインストール

[Kamal公式サイト](https://kamal-deploy.org/docs/installation/) を参考にして Kamal をインストールします。

VSCode で Everdiary を開き (`code path/to/everdiary`)、「コンテナで再度開く」でコンテナを起動します。
そして、VSCode のターミナルで次のコマンドを実行します。

```bash
gem install kamal
```

次に Kamal の初期設定ファイルを自動生成します。

```bash
kamal init
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

#### インスタンスタイプ: t4g.micro

これはRails アプリを動作させるのみ最低限のスペックのものです。t4g.nano はメモリが 0.5 GBしかないので Rails アプリにはきびしいです。メモリ 1GB は不安ですが、もしスペックが足らなくても EC2 ならあとから簡単にスペックを上げられるのがいいですよね。

![t4g.micro](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.28.46.png)

#### キーペア (ログイン): everdiary

新しいキーペアの作成を押して、

![新しいキーペアの作成を押す](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.33.41.png)

- キーペア名: everdiary
- キーペアのタイプ: ED25519
- プライベートキーファイル形式: .pem

を指定して、キーペアを作成します。

![キーペアを作成](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.34.32.png)

ダウンロードした `everdiary.pem` は `~/.ssh` に移動して適切な権限に設定します。

![自動でキーペアをダウンロード](/assets/images/deploy-line-on-rails/SS_2024-09-28T17.43.55.png)

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

表示されたインスタンスの一覧画面から、さらにインスタンスの IDを押して、

![インスタンスの一覧画面](/assets/images/deploy-line-on-rails/SS_2024-09-28T18.03.01.png)

インスタンスが起動していることを確認します。赤枠の箇所が現時点のパブリック IP アドレスです。

![インスタンスの詳細](/assets/images/deploy-line-on-rails/SS_2024-09-28T18.04.49.png)

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

### おわりに

WIP

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
