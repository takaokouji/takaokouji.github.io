---
layout: single
title:  "GitHub Pages + Jeykll + カスタムテーマでブログを開設する"
categories: output setup
tags: jekyll
toc: true
header:
  overlay_image: /assets/images/jekyll-on-github-pages/jekyll-on-github-pages.png
  overlay_filter: 0.4
tagline: ""
last_modified_at: 2021-08-30T22:22:23:46+0900
---
ダメだダメだとわかっていても手段と目的が入れ替わっちゃうんですよね。ブログを書くことが目的なのに、いつのまにかJekyll[^1]のソースコードを読んだり、テンプレートをつくってみたり。新しいことを始めると、そこらじゅうに沼があるので足をとられないように気をつけないといけません。

[^1]: JekyllはGitHub Pagesから利用しやすく、ブログのようなウェブサイトを作りやすいRuby製のソフトウェア

さて、今回の記事は技術的なアウトプット＝「それは○○だよ」です。

このブログを始めるときにやったことをまとめます。一回しかやらないことだからすぐに忘れちゃうんですよね。

{% include advertisements.html %}

まずどのサービスを使うかですが、一瞬悩みましたが私の場合は[GitHub Pages](https://docs.github.com/ja/pages/getting-started-with-github-pages/about-github-pages)一択でした。
そして、GitHub Pagesなら[Jekyll](http://jekyllrb-ja.github.io/)ですね。ここまではスムーズでした。

次はセットアップ。チュートリアル通りにセットアップして初期ページが表示できるところまで。
[Googleで「jekyll github pages」を検索する](https://www.google.com/search?q=jekyll+github+pages&oq=jekyll+github+pages&aqs=chrome.0.69i59l3j0i512j0i30j69i60l3.5652j0j7&sourceid=chrome&ie=UTF-8) とたくさん日本語の記事がでてきますが、[GitHub Pagesの公式ドキュメント](https://docs.github.com/ja/pages/setting-up-a-github-pages-site-with-jekyll)で十分です。

はまるのはここからです。

### デフォルトのテーマ以外のカスタムテーマを使う

残念がら [GitHub Pagesのデフォルトのテーマ](https://pages.github.com/themes/) はしっくりこなかった。使いたいテーマは [mmistakes / minimal-mistakes](https://github.com/mmistakes/minimal-mistakes)。
ローカルで使う分にはテーマの[インストール手順の通り](https://github.com/mmistakes/minimal-mistakes#installation)でOK。

ただ、 jekyll new コマンドで生成したファイルのいくつかを修正する必要があった。[minimal-mistakesテーマのCUSTOMIZATION / Configuration](https://mmistakes.github.io/minimal-mistakes/docs/configuration/) をよく読めば分かるけどデフォルトでいいやって人は、普通読まないよね :smile:

これが結構手間取った。抜けがありそうだけど、だいたい以下のような感じ。

- _config.yml を minimal-mistakes のもので上書きする
  - [4.24.0: minimal-mistakes / _config.yml](https://github.com/mmistakes/minimal-mistakes/blob/00fa7be38b5e57c6539d3986b2168ea7b57bc67a/_config.yml)
  - themeはコメントアウトして remote_theme のみにする。
    - 手元にgemとしてインストール済みのminimal-mistakesが使えないことがちょっと悔しい。なんかよい解決法方はないのかな。
- minimal-mistakes から _data をコピー
  - `navigation.yml` は適切な内容に修正する
- minimal-mistakes から docs/_pages 以下のファイルのいくつかを _pages にコピー。その後、日本語にするなど。
  - category-archive.md: カテゴリー一覧
  - sitemap.md: サイトマップ
  - tag-archive.md: タグ一覧
  - terms.md: 規約とプライバシーポリシー
  - year-archive.md: 記事一覧

それと、themeをコメントアウトせずにpushすると、以下の警告メールがGitHub Pagesから届いた。「デフォルト以外のthemeを使っているよ」と。親切だ。
警告メール。わかりやすい。ありがとう。

```
[takaokouji/takaokouji.github.io] Page build warning

The page build completed successfully, but returned the following warning for the `main` branch:

You are attempting to use a Jekyll theme, "minimal-mistakes-jekyll", which is not supported by GitHub Pages. Please visit https://pages.github.com/themes/ for a list of supported themes. If you are using the "theme" configuration variable for something other than a Jekyll theme, we recommend you rename this variable throughout your site. For more information, see https://docs.github.com/github/working-with-github-pages/adding-a-theme-to-your-github-pages-site-using-jekyll.
(省略)
```

### 絵文字を使いたい

_config.yml の plugins と whitelist に以下を追加するだけ。

```yml
# Plugins (previously gems:)
plugins:
  - jekyll-avatar
  - jekyll-feed
  - jekyll-gist
  - jekyll-include-cache
  - jekyll-mentions
  - jekyll-paginate
  - jekyll-relative-links
  - jekyll-seo-tag
  - jekyll-sitemap
  - jekyll-titles-from-headings
  - jemoji

# mimic GitHub Pages with --safe
whitelist:
  - jekyll-avatar
  - jekyll-feed
  - jekyll-gist
  - jekyll-include-cache
  - jekyll-mentions
  - jekyll-paginate
  - jekyll-relative-links
  - jekyll-seo-tag
  - jekyll-sitemap
  - jekyll-titles-from-headings
  - jemoji
```

なお、GitHub Pagesで使えるプラグインはこれだけなので、他のものを使いたければ手元で jekyll build したものをコミットしてpushすることになるが、gemのバージョンアップとか面倒なので私はこのままで。

### 記事を追加しても表示されない

拡張子をつけるのを忘れてました... :sweat_smile:

```
(失敗: 拡張子なし)
      Regenerating: 1 file(s) changed at 2021-08-30 11:20:18
                    _drafts/jekyll-on-github-pages
      Remote Theme: Using theme mmistakes/minimal-mistakes
       Jekyll Feed: Generating feed for posts
        Pagination: Pagination is enabled, but I couldn't find an index.html page to use as the pagination template. Skipping pagination.
                    ...done in 1.738054 seconds.

(成功: 拡張子.mdあり)
      Regenerating: 1 file(s) changed at 2021-08-30 11:21:04
                    _drafts/jekyll-on-github-pages.md
      Remote Theme: Using theme mmistakes/minimal-mistakes
       Jekyll Feed: Generating feed for posts
        Pagination: Pagination is enabled, but I couldn't find an index.html page to use as the pagination template. Skipping pagination.
                    ...done in 1.769007 seconds.
```

動作ログでは処理しているっぽい感じでエラーが出ないから気がつけなかった。これわかんないでしょ、まじで。
結構な時間、これにハマった。

ただ、生成したウェブページ、CSS、画像はすべて `_sites` 以下にあるのはわかりやすい。どのファイルはOKで、どのファイルはNGなのかすぐに把握できた。すばらしい設計。

### 読了時間が間違ってる。1分以内では読めませんよ。

各記事の読了時間が軒並み1分以内。実際には5分くらいかかりそうなのに。計算方法を調べてみると...

[3.9.0: lib/jekyll/filters.rb#L125](https://github.com/jekyll/jekyll/blob/8fe3a5d59ba659b759ae1f48fe1112a64dd8ea47/lib/jekyll/filters.rb#L125) より
```ruby
def number_of_words(input)
  input.split.length
end
```

うん、これじゃダメだね。日本語だと1文が1つの単語としてカウントされている。
ちなみに最新のJekyllは対応済みで、日本語は文字でカウント。すばらしいです。

[mater: lib/jekyll/filters.rb#L124](https://github.com/jekyll/jekyll/blob/e482574b84ccf0dc93c8bbd8092e5247b87d06c3/lib/jekyll/filters.rb#L124) より
```ruby
def number_of_words(input, mode = nil)
  cjk_charset = '\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}'
  cjk_regex = %r![#{cjk_charset}]!o
  word_regex = %r![^#{cjk_charset}\s]+!o

  case mode
  when "cjk"
    input.scan(cjk_regex).length + input.scan(word_regex).length
  when "auto"
    cjk_count = input.scan(cjk_regex).length
    cjk_count.zero? ? input.split.length : cjk_count + input.scan(word_regex).length
  else
    input.split.length
  end
end
```

Jekyllをバージョンアップすることも、プラグインをインストールすることもやりたくないので、[Qiita Jekyllで日本語の文字カウントに対応させる - Qiita](https://qiita.com/mt_west/items/c2a473285c3c3e8419ad) を参考にして対応した。
[minimal-mistakes の _includes/page__meta.html](https://github.com/mmistakes/minimal-mistakes/blob/00fa7be38b5e57c6539d3986b2168ea7b57bc67a/_includes/page__meta.html) をコピーして、単語のカウント処理を以下のように書き換えた。

{% raw %}
```
(修正前)
{% assign words = document.content | strip_html | number_of_words %}

(修正後)
{% assign words = document.content | strip_html | strip_newlines | size %}
```
{% endraw %}

そのうちGitHub PagesのJekyllのバージョンが上がれば `number_of_words: 'auto'` に変える予定。

### Google AdSense

まだ承認されていないけど設定しておいた。

_includes/advertisements.html に Google AdSense で取得したコードを記述。
広告を表示したい記事で以下を記述する。

{% raw %}
```
{% include advertisements.html %}
```
{% endraw %}

### 各種サービスの有効化

有効にしたサービスは以下。設定の項目名のみだけど。各サービスの設定は省略。

- google_site_verification
- twitter
- facebook
- analytics.provider: "google"

### 記事に画像を追加

記事のプロパティに以下を追加。

```yaml
header:
  image: /assets/images/jekyll-on-github-pages/jekyll-on-github-pages.png
```
