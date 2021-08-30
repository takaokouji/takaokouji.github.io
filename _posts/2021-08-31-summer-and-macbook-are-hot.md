---
layout: single
title:  "PCクーラーだけじゃなかった！熱すぎるMacBook Proを冷ますのに効果的なもの"
categories: buy
tags:
header:
  overlay_image: /assets/images/summer-and-macbook-are-hot/B085QJB58B.jpg
  overlay_filter: 0.4
  caption: "Photo from [**Amazon商品ページ**](https://amzn.to/3zuCpgx)"
tagline: "私だけのためにクーラーでガンガン冷やすのはちょっとね"
last_modified_at: 2021-08-31T00:00:12:51+0900
---
今年の夏も暑い。昨年とは違いフルリモートでの自宅作業。日中は仕事部屋にこもっているんだけど、私だけのためにクーラーでガンガン冷やすのはちょっとね。

ぎりぎり扇風機で耐えられる暑さだったので、クーラーを使わずにいたら、まぁ、 MacBook Pro の暑いこと暑いこと。仕事の都合で M1 じゃないやつ[^1]を2台つかっているんだけど、低温やけどしそうなくらいの熱さだし、あきらかに処理速度が遅くなっている。これはまずい、なんとかしなければ！

ってことで、熱すぎるMacBook Proを冷ますのに効果的な〇〇を購入しました。

[^1]: M1 の MacBook Pro はクーラーなしでも熱くならず、処理速度は変わらないんだろうか？チャンスがあれば試してみたい。

{% include advertisements.html %}

それは、こちらです！

<a target="_blank" href="https://www.amazon.co.jp/gp/product/B085QJB58B/ref=as_li_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=B085QJB58B&linkCode=as2&tag=takaokouji-22&linkId=a8c6e49d5a242cfca6085e946179084c">トップランド 卓上扇風機 小型 [どこでもFAN ホーム &amp; アウトドア] 3WAY電源 上下角度調節 風量調節3段階 切タイマー搭載 ブラック SF-DF35 BK</a>
<iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="https://rcm-fe.amazon-adsystem.com/e/cm?ref=qf_sp_asin_til&t=takaokouji-22&m=amazon&o=9&p=8&l=as1&IS2=1&detail=1&asins=B085QJB58B&linkId=8e7c30841c1066592275d607e5cbeb31&bc1=000000&amp;lt1=_blank&fc1=333333&lc1=0066c0&bg1=ffffff&f=ifr">
    </iframe>

... **卓上扇風機** です。そのまんまです。

でも、これなかなかいいですよ。

- キーボードとパームレストがよく冷える。手は涼しくなりました。というか寒いくらい。
- 弱・中・強の3段階の速度調整がきちんとできる。それぞれの速度がはっきりと違う。
- 軽くて持ち運びが簡単。ついつい持ち歩きたくなる。
- デザインがよい。自慢したくなる。
- モバイルバッテリーでもOK。体育館でのスポーツ観戦やキャンプでも使えそう。

まぁね、悪いところもありますよ。

- それなりに音がうるさい。寝静まったときには使いにくい。
- **CPU、GPUは冷えない** 。 [iStats gem](https://github.com/Chris911/iStats) の istats コマンドでちょいちょいみてたんですが、 Docker で自動テストを実行したらダメですね。すぐに熱くなります。

えっ！？最後のやつ、だめじゃん。

そうなんですよ、手元は冷えてもCPUは熱いままなんですよ。

実は、はじめはPCクーラーを買おうと思って探していました。価格・機能・デザインのすべてにおいて気にいった商品をみつけました。
<a target="_blank" href="https://www.amazon.co.jp/gp/product/B07281KZRJ/ref=as_li_tl?ie=UTF8&camp=247&creative=1211&creativeASIN=B07281KZRJ&linkCode=as2&tag=takaokouji-22&linkId=68718864fa2254f0024ef4b6b3419f13">エレコム USB扇風機 縦置き/横置き/ PC&amp;タブレット冷却台 3段階風量調整 ブラック FAN-U177BK</a>
<iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="https://rcm-fe.amazon-adsystem.com/e/cm?ref=qf_sp_asin_til&t=takaokouji-22&m=amazon&o=9&p=8&l=as1&IS2=1&detail=1&asins=B07281KZRJ&linkId=fae18e2a8417b7de2a0bb0d326631af8&bc1=000000&amp;lt1=_blank&fc1=333333&lc1=0066c0&bg1=ffffff&f=ifr">
    </iframe>

で、ポチろうとしたら、こんなレビューを見つけたんですよね。

[ノートPCに使った場合、CPUやGPUの温度が下がらないと意味がない。 - エレコム USB扇風機 縦置き/横置き/ PC&タブレット冷却台 3段階風量調整 ブラック FAN-U177BK](https://www.amazon.co.jp/gp/customer-reviews/R1A72RM5CC6Y69/ref=cm_cr_dp_d_rvw_ttl?ie=UTF8&ASIN=B07281KZRJ) より
> こういったものは、主観評価を見て買ってはいけないものだと思います。
> (省略)
> 実際、ノートパソコンの背面に配置してみて、CPUやGPU温度を測定しましたが1度も私のPCは落ちませんでした。
> 私は、吹き込み型の冷却台はどれも同じ結果になっています。

まじか！？ってなりますよね。

気になって MacBook Pro の排気口の位置や形状を確認したり、分解画像を確認したりすると、たしかに背面から風を取り込むようになっていません。また、内蔵ファンで熱風を外に出す仕組みなので、PCクーラーがその熱風を押し返してしまうことも懸念されます。結果、 **CPUやGPUを冷やすことは諦めた** んですよね。

それで、せめてキーボードやパームレスト(キーボード手前の手のひらをおくところ)だけでも冷やせないかなと思って卓上扇風機を買うことにしました。

少しずつ涼しくなってきてますし、今年の夏は **卓上扇風機** で乗り越えようと思ってます！
