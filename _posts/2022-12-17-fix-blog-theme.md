---
layout: single
title:  "n回目のブログ再開宣言！"
categories: diary
tags:
toc: false
last_modified_at: 2022-12-17T22:22:30:29+0900
---

しばらくぶりのブログ更新になってしまいました。なんかすみません。
ブログを書かないと書けなくなるという悪循環におちいるので、今回こそは続けたい。が、3日坊主もそれを繰り返せば習慣になるという誰かの教えに従うことにして、中断しても気にしないでいこうと思っています。

で、今回はこのブログテーマのカスタマイズについて書きます。
GitHub Pages + Jekyll + Minimal Mistakes という限定的な話なので、あまり約には立たないかもしれませんね...

{% include advertisements.html %}

このブログは、 [GitHub Pages](https://docs.github.com/ja/pages/getting-started-with-github-pages/about-github-pages) 上で [Jekyll](https://jekyllrb.com/) というソフトウェアを使ってMarkdownの文章からHTMLを生成しています。また、テーマとして [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) を採用しています。無料で広告も可能。大量アクセスにも耐えられるシステム。さらに、ブログを運用するためのシステム的なノウハウもそこそこ得ることができます。私にはちょうどよいものです。

で、その [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) というテーマで、少し気にいらないところがあります。目指したいのは [Zenn](https://zenn.dev/) や [Qiita](https://qiita.com/)。でも、やたらでかいんですよね。フォントが。調べると22pxくらいありました。ブラウザの横幅によって自動的にフォントサイズが大きくなるようになっています。それ自体はすばらしいのですが、技術文章でフォントサイズが大きいのは致命的です。ソースコードとかすぐに改行されてしまって、見にくいです。

そこで、フォントサイズを変更しました。以下の内容の `assets/css/main.scss` を作成すると実現できました。横幅によらず 16px にしています。
```scss
---
# Only the main Sass file needs front matter (the dashes are enough)
search: false
---

@charset "utf-8";

@import "minimal-mistakes/skins/{{ site.minimal_mistakes_skin | default: 'default' }}"; // skin
@import "minimal-mistakes"; // main partials

html {
  font-size: 16px;
}
```

[Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) の公式サイトに、[カスタマイズ方法:Customizing](https://mmistakes.github.io/minimal-mistakes/docs/stylesheets/#customizing) が記述してありました。2つやり方があり、今回は2番目の方法にしています。うろ覚えですが、最初のものは GitHub Pages だと使えなかった気がします。テーマに関しては GitHub Pages は制限が多いです。

> Copy from this repo.
>
> Copy the contents of assets/css/main.scss to <your_project>.
> Customize what you want inside <your_project/assets/css/main.scss.

フォントサイズが変わると全然印象が変わりますね。
これでテーマのカスタマイズ方法がわかったので、 [Zenn](https://zenn.dev/) を目指して、ちょっとずつ改良していこうと考えています。少し楽しみ。
