---
layout: single
title:  "Google Search Console に sitemap.xml を追加したい！"
categories: output setup
tags: jekyll
header:
  overlay_image: /assets/images/wanna-submit-sitemap/google-search-console-sitemap.png
  overlay_filter: 0.4
tagline: "だけどできないのはなぜ？"
last_modified_at: 2021-09-05T22:22:25:41+0900
---
[Google Search Console](https://search.google.com/search-console) に [sitemap.xml](https://takaokouji.github.io/sitemap.xml) を追加できない。
(追記: 2021-09-05T22:22:23:56+0900) 無事追加できた。特に何もしていない。サイトができてからしばらくしないといけないとか？

sitemap.xml にアクセスするとそれっぽい XML を返している。
それに、 [XML Sitemap Validator - XML-Sitemaps.com](https://www.xml-sitemaps.com/validate-xml-sitemap.html?op=validate-xml-sitemap&go=1&sitemapurl=https%3A%2F%2Ftakaokouji.github.io%2Fsitemap.xml&submit=Validate+Sitemap) でチェックしても問題は見つからない。

追加できないのはなぜ？

{% include advertisements.html %}

Googleで調べたところ、最後のものが有力。つまり、 Google に相談しろと。

- sitemap.xml は [jekyll-sitemap](https://github.com/jekyll/jekyll-sitemap) プラグインで自動生成する。
- sitemap.xml をコミットしている場合、 GitHub Pages が自動生成したものが上書きしてしまい、正しく動作しないことがあるらしい。
  - [Troubleshooting: XML Sitemap when hosting on GitHub](https://www.cross-validated.com/XML-Sitemap-Problem-when-hosting-on-GitHub/)
- プラグインを利用せずに sitemap.xml を出力することもできるらしい。
  - [Generating a basic sitemap.xml with Jekyll](http://www.independent-software.com/generating-a-sitemap-xml-with-jekyll-without-a-plugin.html)
- 同様の問題が発生していたが Google に問い合わせてしばらくすると解決したらしい。
  - [Google deliberately does not accept sitemap.xml of Github Pages](https://github.community/t/google-deliberately-does-not-accept-sitemap-xml-of-github-pages/184937)

とりあえず Google にフィードバックを送ることにした。進展があれば追記する予定。

- - -

あと余談だけど、これ、すごい便利。
![フィードバックのUI](/assets/images/wanna-submit-sitemap/google-search-console-feedback-ui.png)
これは Google にフィードバックを送るときのUIなんだけど、自動でスクリーンショットが撮られて、ドラッグ&ドロップで注目してほしい箇所を選択できて、必要なら説明も追加できる。

こういうのほしいよね。
