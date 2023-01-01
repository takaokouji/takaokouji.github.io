---
layout: single
title:  "CoderDojoしまね・オンラインを開催しました！"
categories: diary
tags: progshou event
toc: true
last_modified_at: 2021-09-11T18:18:08:25+0900
---
CoderDojoしまねをオンライン(Zoom)で開催しました。

参加された方は、

- メンター(先生): 4名
- ニンジャ(児童・生徒): 3名

でした。ありがとうございました。

{% include advertisements.html %}

## テーマ

今回のテーマは「算数をプログラムにとりいれよう」でした。
([これまでのテーマ・教材の一覧](https://github.com/smalruby/smalruby.jp/wiki/%E3%83%86%E3%83%BC%E3%83%9E%E4%B8%80%E8%A6%A7%E3%82%84%E6%95%99%E7%A7%91%E6%9B%B8))

## わんすく

今回のわんすく[^1] は [10 Pita ☁ ｜｜ Mobile Support Ver1.0 #Game](https://scratch.mit.edu/projects/559105914/) でした。

[^1]: 「わんすく」とは、すばらしい (ワンダフルな) スクラッチ、スモウルビーのプログラムの紹介するコーナーのことです。


![10 Pita サムネイル]({{site.baseurl}}/assets/images/coderdojo-shimane-2021-09-11-online/10pita-thumbnail.png)

### 遊び方

> ？に入る数字を左上から選ぶだけです。
> 算数の穴あけが元ネタです。
> スコアが伸びるにつれタイマーが短くなります。

足して10になる数字を選んでクリックするだけという単純なゲームです。
デザインの良さ、簡単な操作、ドキドキさせる音楽、と非常に完成度の高い作品です。
気がついたらムキになってやってました。

![10 Pita プレイ画面1]({{site.baseurl}}/assets/images/coderdojo-shimane-2021-09-11-online/10pita-play.png)
![10 Pita プレイ画面2]({{site.baseurl}}/assets/images/coderdojo-shimane-2021-09-11-online/10pita-play2.png)

ミスする、または時間切れになるとゲームオーバー。スコアも表示されます。
![10 Pita スコア画面]({{site.baseurl}}/assets/images/coderdojo-shimane-2021-09-11-online/10pita-score.png)

あえてプレイ中はスコアを表示していない点もイイですね。「あと何点でゴールだ」ではなく、「ここまでやったら大丈夫かな？いやもっとやらないとダメかも...」というドキドキ感がずっと続きます。

### 中を見る

さて、プログラムの中を見てみましょう。注目するのは数字の(1)のスプライトの、押した数字が正しいかどうかを判定するところです。

![10 Pita コード]({{site.baseurl}}/assets/images/coderdojo-shimane-2021-09-11-online/10pita-code.png)

変数「判定2」はゲーム中かどうかを扱うもので、`1` ならゲーム中です。ゲーム開始時にCatスプライトで `1` にしています。

クリックされたときに今の数字が9だったら、クリックした数字の1と足すと10になるので正解にします。
とても単純ですね。

### Ruby

スモウルビーを使ってRubyのコードの表現を見てみましょう

```ruby
self.when(:clicked) do
  if $判定2 == 1
    if $今の数字 == 9
      broadcast("正解")
      broadcast("1")
    else
      broadcast("不正解")
    end
  end
end
```

- `self.when(:clicked) do` は「このスプライトが押されたとき」
- `==` は「(  ) = (  )」。Rubyだと等しいかどうかを調べるには `=` を２つ重ねます
- `broadcast` は「〜を送る」

## 次回

次回のCoderDojoしまね・オンラインは 2021/10/09 13:30-15:30 (13:15開場) です。

申し込み・接続方法(Zoomの会議室ID、パスワード)は [申し込みフォーム](https://forms.gle/e3SWaMxUXKqxedvD7) からお願いします。

開催連絡はNPO法人Rubyプログラミング少年団の公式LINEでも行っています。ぜひ友達になってください！
<a href="https://lin.ee/aJwgLOQ"><img src="https://scdn.line-apps.com/n/line_add_friends/btn/ja.png" alt="友だち追加" height="36" border="0"></a>
