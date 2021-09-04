---
layout: single
title:  "Ruby on Railsのメインターゲット、Basecampを試す！"
header:
  overlay_image: /assets/images/try-basecamp/fbo-on-basecamp.png
  overlay_filter: 0.4
tagline: "メインターゲット = Basecampは高尾個人の考えですのであしからず..."
categories: diary
tags:
last_modified_at: 2021-09-05T01:01:23:44+0900
---
ゴールド・プロダクトマネージャー
ゴールド・プロダクトマネージャー
ゴールド・プロダクトマネージャー
.
...
.....
ド〜ん！？

まいど、ゴールド・プロダクトマネージャーです！

**プロダクトマネージャー** という役割を知ってからというもの、日々、「私がプロダクトマネージャーだったらどうするか」ということを考えながら、ザク的な開発者[^1]として受託 or 委託開発を行っています。

[^1]:安心してください。[機動戦士ガンダム THE ORIGIN](https://amzn.to/3BJq8W2)によってザクの圧倒的強さは知っていますから。ただ、ここではガンダム登場以降のザクを想定し、その他大勢の開発者の一人ということで「ザク的な開発者」と表現しています。

でもやっぱりね、なにか作りたくなるんですよね。

だから、プロダクトマネージャーと並行して学んでいる **OKR に関するウェブアプリ** を作ってやろうと企んでいます。

{% include advertisements.html %}

[OKR](https://en.wikipedia.org/wiki/OKR) は目標を達成するためのやり方の一つで、それを中学生の部活動に取り入れられないかと思っていろいろ考えています。毎週・毎日の目標と到達度の確認にはアプリケーションが役立つのは間違いないでしょう。
<iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="//rcm-fe.amazon-adsystem.com/e/cm?lt1=_blank&bc1=000000&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=takaokouji-22&language=ja_JP&o=9&p=8&l=as4&m=amazon&f=ifr&ref=as_ss_li_til&asins=4822255646&linkId=3225fb91e90ad6d7f2425261a251421e"></iframe>

そして、中学生といえばLINEです。中学生が携帯をほしがる理由はLINEをしたいから。6割近くの友達がLINEでやりとりしているのだから自分も加わりたくなるのは当然です。

で、これから作るアプリではそのLINEをつかってみようかと考えています。
**OKR + LINE を Rails で開発する** 。いや〜、楽しみです。

- - -

ここでふと、「巷にはたくさんあるウェブアプリケーションフレームがあるけど、そもそも **Rails ってどんなウェブアプリを作るのに適しているんだろう？** 」という疑問がわきました。

というのも、私が最初にRailsをさわったときはバージョン 1.1 の頃で、JavaのStrutsくらいしかかっちりしたものはなく、それぞれの言語で独自にウェブアプリを作っていた時代でした。

私は Railsを使うようになってからは、ウェブアプリならなんでもRailsを使って作るようになりました。他の選択肢はほとんど考えませんでした。

時は進み、今は2021年です。Railsの登場から15年以上も経ち、巷には様々なウェブアプリケーションフレームがあります。今回の開発するアプリでも Rails でいいのだろうかと不安になります。その不安を払拭するためにも、Railsで開発しやすい規模感のウェブアプリを知りたい。

で、 **Rails といえば [Basecamp](https://basecamp.com/) がメインターゲットだと言っても過言ではない** ので試してみました。これまで使ったことなかったんですよね。

Basecamp の料金、アカウントの作成方法、簡単な使い方は以下が詳しいです。というか全部わかります。ので、私は説明しません :smile:
[タスク管理ツールBasecamp(ベースキャンプ)とは？概要や使い方を紹介 - タスク管理ツール.com](https://xn--pcktarw9qud7338c9ym.com/?p=2668)

ざっと使ってみた感想です。そして、残念ながら今回のアプリ開発に Basecamp は使えそうにありません。

- 画面がシンプル。1画面に1機能って感じ
- SPAじゃないけどユーザー体験はSPAそのもの。本気の [turbolinks](https://github.com/turbolinks/turbolinks) はすごい。
  - って思ったら turbolinks は終わっていて [Hotwire](https://hotwired.dev/) になってた
- チャットやメッセージなどのリアルタイム通信をやっていてすごい
- URLがRESTfulできれい
- 機能が少ない。6つ or 7つ
- GitHubとの連携も単体ではできないため **ソフトウェア開発には使えない**
  - [ZenHub](https://www.zenhub.com/) が圧倒的に使いやすい

ただ、当初の疑問は解消しました。

- シンプルな画面
- 〜7程度の少ない機能

というのが、Rails が適しているウェブアプリと言えそう。これまでに培ってきた受託 or 委託開発での経験とも合致します。今回のアプリには、やはり Rails が最適ですね。自信を持って開発を進められそうです。

ちなみに、これ以上の規模だと DB は共通にしてアプリを分けるか、Rails (Ruby) 以外を採用するか、人を増やしてなんとかするか...。

- - -

最後に、Basecamp の UI がすてきだったので、どんな JavaScript のライブラリを使っているのか調べてみました。

[libraries-0dc07b17bfc4f8313c86.js.LICENSE.txt](https://bc3-production-assets-cdn.basecamp-static.com/assets/packs/js/libraries-0dc07b17bfc4f8313c86.js.LICENSE.txt) より

- Sizzle CSS Selector Engine v2.3.5
- jQuery JavaScript Library v3.5.0
- jQuery UI Core 1.11.4
- jQuery UI - v1.11.4 - 2015-08-30
- jQuery UI Datepicker 1.11.4
- jQuery outside events - v1.1 - 3/16/2010
- Polymer
- TraceKit - Cross brower stack traces

これとあと [Hotwire](https://hotwired.dev/) 関連なのでしょう。

なんか **jQuery が使われていて安心しました** 。これからも使っていいんだと。
(でも、いまどき jQuery を推すと老害だと言われそうで怖い。気のせいだといいんですけどね。)
