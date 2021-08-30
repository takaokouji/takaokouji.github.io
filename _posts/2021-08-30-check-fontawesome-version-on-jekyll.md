---
layout: single
title: "利用中のFontawesomeのバージョンの確認方法"
categories: output setup
tags: jekyll
---
[fontawesome.com](https://fontawesome.com/) でアイコンを検索 → コピペ → 表示されない、ってこれ、何回同じことをするんだよ。アイコンが表示できない原因のひとつはFontawesomeのバージョンが違うこと。

いいかげん、利用しているFontawesomeのバージョンを調べる方法を把握しておく。

{% include advertisements.html %}

1. 対象のウェブサイトをChromeで開く
2. デベロッパーツールを開く
   - ショットーカットキーは `command` + `option` + `I`
3. Elementsタブで `fontawesome` を検索
   - 検索のショットーカットキーは `command` + `F`

GitHub Pages + Jekyllでは以下のHTML要素が見つかった。`@fortawesome/fontawesome-free@5` ってことはバージョン5を利用しているってこと。

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@5/css/all.min.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
```

各バージョンのアイコンを検索するためのリンクを挙げておく。いずれもメニューの「Icons」を押すとアイコンを検索できる。
- [バージョン6](https://fontawesome.com/v6.0)
- [バージョン5](https://fontawesome.com/v5/changelog/latest)
- [バージョン4](https://fontawesome.com/v4.7/)

使いたかったアイコンはメガホン
<i class="fas fa-bullhorn" aria-hidden="true"></i>

```html
<p class="small">
    <i class="fas fa-bullhorn" aria-hidden="true"></i>
    Google広告
</p>
```

って感じで「 Google 広告」の前に置きたかったんだよね。なんとなくだけど。

それと、アイコンが表示されない原因は `fa-bullhorn` のほうではなく `fas` のほうだった。そっちも合わせないといけないんだ。奥深い。
(おっと、また手段と目的が変わってしまってた。あぶない、あぶない。)
