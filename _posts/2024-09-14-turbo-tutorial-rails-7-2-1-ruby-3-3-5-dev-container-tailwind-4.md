---
layout: single
title: "Turbo Rails Tutorial を Rails 7.2.1 / ruby 3.3.5 / Dev Container / tailwindcss でやってみた (4)"
categories: output
tags: ruby rails turbo devcontainer
toc: true
last_modified_at: 2024-09-14T11:00:00+0900
---

[前回の続き]({% post_url 2024-09-12-turbo-tutorial-rails-7-2-1-ruby-3-3-5-dev-container-tailwind-3 %}) です。[Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) と [tailwindcss](https://tailwindcss.com/) を利用して [Turbo Rails Tutorial](https://www.hotrails.dev/turbo-rails) をやっています。

今回は CSS ファイルの分割と [CSS 入れ子 (CSS nesting)](https://developer.mozilla.org/ja/docs/Web/CSS/CSS_nesting) をできるようにします。

前回までソースコードは [takaokouji/quote-editor:7e07238](https://github.com/takaokouji/quote-editor/tree/7e07238a84f1d7c12d0055dada65f82b214c9026) にあります。

### 環境

- Apple M3 (MacBook Air 13 2024)
- macOS Sonoma 14.6.1
- [Homebrew](https://brew.sh/ja/)
- Visual Studio Code 1.93.0
  - Dev Container 機能拡張をインストール済み
- ruby 3.3.5
  - [anyenv](https://github.com/anyenv/anyenv) で [rbenv](https://github.com/rbenv/rbenv) をインストール
  - ruby 3.3.5 を global に設定済み ( `rbenv global 3.3.5` )
- rails 7.2.1 gem
  - `gem install rails`
- 他のソフトウェアは Docker コンテナ上にインストール

### PostCSSの導入

[公式のドキュメント](https://tailwindcss.com/docs/using-with-preprocessors#using-post-css-as-your-preprocessor) には tailwindcss を使いつつ、ファイル分割と CSS 入れ子を実現するには PostCSS を使う、とあります。

[ファイル分割](https://tailwindcss.com/docs/using-with-preprocessors#build-time-imports)

> One of the most useful features preprocessors offer is the ability to organize your CSS into multiple files and combine them at build time by processing @import statements in advance, instead of in the browser.
>
> The canonical plugin for handling this with PostCSS is postcss-import.

[CSS 入れ子](https://tailwindcss.com/docs/using-with-preprocessors#nesting)

> To add support for nested declarations, we recommend our bundled tailwindcss/nesting plugin, which is a PostCSS plugin that wraps postcss-nested or postcss-nesting and acts as a compatibility layer to make sure your nesting plugin of choice properly understands Tailwind’s custom syntax.

早速 PostCSS を導入します。railsコマンド一発で完了です。railsすごい！

```bash
bin/rails css:install:postcss
```

ただ、これが何しているのかが知っておきたいので、実行ログを詳しく見てみます。

```text
       apply  /home/vscode/.rbenv/versions/3.3.5/lib/ruby/gems/3.3.0/gems/cssbundling-rails-1.4.1/lib/install/postcss/install.rb
       apply    /home/vscode/.rbenv/versions/3.3.5/lib/ruby/gems/3.3.0/gems/cssbundling-rails-1.4.1/lib/install/install.rb
    Build into app/assets/builds
       exist      app/assets/builds
   identical      app/assets/builds/.keep
   unchanged      app/assets/config/manifest.js
    Stop linking stylesheets automatically
        gsub      app/assets/config/manifest.js
   unchanged      .gitignore
   unchanged      .gitignore
    Remove app/assets/stylesheets/application.css so build output can take over
      remove      app/assets/stylesheets/application.css
    Add stylesheet link tag in application layout
   unchanged      app/views/layouts/application.html.erb
   unchanged      Procfile.dev
    Add bin/dev to start foreman
   identical      bin/dev
  Install PostCSS w/ nesting and autoprefixer
      create    postcss.config.js
      create    app/assets/stylesheets/application.postcss.css
         run    yarn add postcss postcss-cli postcss-import postcss-nesting autoprefixer from "."
yarn add v1.22.22
[1/4] Resolving packages...
[2/4] Fetching packages...
warning Pattern ["postcss@^8.4.45"] is trying to unpack in the same destination "/home/vscode/.cache/yarn/v6/npm-postcss-8.4.45-538d13d89a16ef71edbf75d895284ae06b79e603-integrity/node_modules/postcss" as pattern ["postcss@^8.4.23"]. This could result in non-deterministic behavior, skipping.
[3/4] Linking dependencies...
[4/4] Building fresh packages...
success Saved lockfile.
success Saved 29 new dependencies.
info Direct dependencies
├─ autoprefixer@10.4.20
├─ postcss-cli@11.0.0
├─ postcss-import@16.1.0
├─ postcss-nesting@13.0.0
└─ postcss@8.4.45
info All dependencies
├─ @csstools/selector-resolve-nested@2.0.0
├─ @csstools/selector-specificity@4.0.0
├─ @sindresorhus/merge-streams@2.3.0
├─ autoprefixer@10.4.20
├─ cliui@8.0.1
├─ dependency-graph@0.11.0
├─ escalade@3.2.0
├─ fs-extra@11.2.0
├─ get-caller-file@2.0.5
├─ get-stdin@9.0.0
├─ globby@14.0.2
├─ graceful-fs@4.2.11
├─ ignore@5.3.2
├─ jsonfile@6.1.0
├─ path-type@5.0.0
├─ postcss-cli@11.0.0
├─ postcss-import@16.1.0
├─ postcss-nesting@13.0.0
├─ postcss-reporter@7.1.0
├─ postcss@8.4.45
├─ pretty-hrtime@1.0.3
├─ require-directory@2.1.1
├─ slash@5.1.0
├─ thenby@1.3.4
├─ unicorn-magic@0.1.0
├─ wrap-ansi@7.0.0
├─ y18n@5.0.8
├─ yargs-parser@21.1.1
└─ yargs@17.7.2
Done in 12.35s.
  Add build:css script
  Add build:css script
         run    npm pkg set scripts.build:css="postcss ./app/assets/stylesheets/application.postcss.css -o ./app/assets/builds/application.css" from "."
         run    yarn build:css from "."
yarn run v1.22.22
$ postcss ./app/assets/stylesheets/application.postcss.css -o ./app/assets/builds/application.css
Done in 0.70s.
         run  bundle install --quiet
```

ここから次のことがわかりました。

- PostCSS の設定ファイル `postcss.config.js` が追加されたこと
- PostCSS の CSS ファイル `app/assets/stylesheets/application.postcss.css` が追加されたこと
- npm の `postcss` `postcss-cli` `postcss-import` `postcss-nesting` `autoprefixer` パッケージが追加されたこと
- CSS をビルドするコマンドが `postcss ./app/assets/stylesheets/application.postcss.css -o ./app/assets/builds/application.css` に変更されたこと

これだけで PostCSS を使う準備がほとんど整いました。

あとは、前回作成した tailwindcss の CSS を PostCSS から使えるようにするだけです。

`postcss.config.js` に tailwindcss の設定を追加して、

```javascript
module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-nesting'),
    require('tailwindcss'),
    require('autoprefixer'),
  ]
}
```

`app/assets/stylesheets/application.tailwind.css` の内容を `app/assets/stylesheets/application.postcss.css` に転記します。そして、`@tailwind base;` を `@import "tailwindcss/base";` に変えます。他の `@tailwind` も変えます。

```css
/* Entry point for your PostCSS build */
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

/* ここから下は app/assets/stylesheets/application.tailwind.css のまま */
```

`tailwind.config.js` はそのままで OK。

最後に `app/assets/stylesheets/application.tailwind.css` を削除して、 `bin/dev` を再起動します。

これで OK。rails がコマンドを提供してくれていたので、簡単に PostCSS を導入できました。

#### ファイル分割

次はファイル分割です。

`app/assets/stylesheets/application.postcss.css` の内容を複数のファイルに分割して転記します。ファイルのパスはチュートリアルに従います。

`app/assets/stylesheets/config/reset.css`

```css
html {
  @apply overflow-y-scroll h-full;
}

body {
  @apply flex flex-col min-h-full bg-background text-text-body leading-normal font-sans;
}

img,
picture,
svg {
  @apply block max-w-full;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  @apply text-text-header leading-tight;
}

h1 {
  @apply text-3xl;
}

h2 {
  @apply text-2xl;
}

h3 {
  @apply text-xl;
}

h4 {
  @apply text-lg;
}

a {
  @apply text-primary no-underline transition-colors duration-200
    hover:text-primary-rotate focus:text-primary-rotate active:text-primary-rotate;
}
```

`app/assets/stylesheets/components/btn.css`

```css
@layer components {
  .btn {
    @apply
      inline-block
      py-1.5 px-4
      rounded-md
      bg-origin-border
      bg-transparent
      border-solid border-2 border-transparent
      font-bold
      no-underline
      cursor-pointer
      outline-none
      [transition:filter_400ms,color_200ms]
      hover:[transition:filter_250ms,color_200ms]
      focus:[transition:filter_250ms,color_200ms]
      focus-within:[transition:filter_250ms,color_200ms]
      active:[transition:filter_250ms,color_200ms];
    }

  .btn--primary {
    @apply text-white bg-gradient-to-r from-primary to-primary-rotate
      hover:text-white hover:saturate-[1.4] hover:brightness-[115%]
      focus:text-white focus:saturate-[1.4] focus:brightness-[115%]
      focus-within:text-white focus-within:saturate-[1.4] focus-within:brightness-[115%]
      active:text-white active:saturate-[1.4] active:brightness-[115%];
  }

  .btn--secondary {
    @apply text-white bg-gradient-to-r from-secondary to-secondary-rotate
      hover:text-white hover:saturate-[1.2] hover:brightness-[110%]
      focus:text-white focus:saturate-[1.2] focus:brightness-[110%]
      focus-within:text-white focus-within:saturate-[1.2] focus-within:brightness-[110%]
      active:text-white active:saturate-[1.2] active:brightness-[110%];
  }

  .btn--light {
    @apply text-dark bg-light
      hover:text-dark hover:brightness-[92%]
      focus:text-dark focus:brightness-[92%]
      focus-within:text-dark focus-within:brightness-[92%]
      active:text-dark active:brightness-[92%];
  }

  .btn--dark {
    @apply text-white border-dark bg-dark
      hover:text-white
      focus:text-white
      focus-within:text-white
      active:text-white;
  }
}
```

`app/assets/stylesheets/components/quote.css`

```css
@layer components {
  .quote {
    @apply flex justify-between text-center items-center gap-3 bg-white rounded-md shadow-sm mb-4 p-2
      md:py-2 md:px-4;
  }

  .quote__actions {
    @apply flex flex-[0_0_auto] gap-2 self-start;
  }
}
```

`app/assets/stylesheets/components/form.css`

```css
@layer components {
  .form {
    @apply flex flex-wrap gap-2;
  }

  .form__group {
    @apply flex-1;
  }

  .form__input {
    @apply block w-full max-w-full py-1.5 px-2 border-solid border-2 border-light rounded-md outline-none
      transition-shadow duration-200
      focus:[box-shadow:0_0_0_2px_theme(colors.glint)];
  }

  .form__input--invalid {
    @apply border-primary;
  }
}
```

`app/assets/stylesheets/components/visually-hidden.css`

```css
@layer components {
  /* Shamelessly stolen from Bootstrap */
  .visually-hidden {
    @apply !absolute !w-px !h-px !p-0 !-m-px !overflow-hidden ![clip:rect(0,0,0,0)] !whitespace-nowrap !border-0;
  }
}
```

`app/assets/stylesheets/components/error-message.css`

```css
@layer components {
  .error-message {
    @apply w-full text-primary bg-primary-bg p-2 rounded-md;
  }
}
```

`app/assets/stylesheets/layouts/container.css`

```css
@layer components {
  .container {
    @apply w-full pr-2 pl-2 ml-auto mr-auto md:pr-4 md:pl-4 md:max-w-[60rem];
  }
}
```

`app/assets/stylesheets/layouts/header.css`

```css
@layer components {
  .header {
    @apply flex flex-wrap gap-3 justify-between mt-4 mb-6 md:mb-8;
  }
}
```

ここまで。

分割できたら `app/assets/stylesheets/application.postcss.css` を修正して、それらを読み込むようにします。

```css
/* Entry point for your PostCSS build */
@import "tailwindcss/base";
@import "./config/reset.css";

@import "tailwindcss/components";
@import "./components/btn.css";
@import "./components/quote.css";
@import "./components/form.css";
@import "./components/visually-hidden.css";

@import "./layouts/container.css";
@import "./layouts/header.css";

@import "tailwindcss/utilities";
```

これで CSS ファイルを分割できました。ブラウザで一通り操作して、見た目が変わっていないことを確認します。

#### CSS 入れ子

次は [CSS 入れ子 (CSS nesting)](https://developer.mozilla.org/ja/docs/Web/CSS/CSS_nesting) に対応します。

`postcss.config.js` の `require('postcss-nesting'),` を `require('tailwindcss/nesting')` に書き換えます。

```javascript
module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss/nesting'),
    require('tailwindcss'),
    require('autoprefixer'),
  ]
}
```

これでSASSを使っているチュートリアルのように CSS ファイルで `&` を使えるようになります。

余談ですが、「CSS 入れ子」といってもブラウザが標準で対応している [CSS nesting](https://www.w3.org/TR/css-nesting-1/) ([日本語訳](https://triple-underscore.github.io/css-nesting-ja.html)) と、 SASS などの CSS プリプロセッサで処理する必要がある CSS nested があります。nesting と nested は、どちらもほぼ同じようなものなのですが、チュートリアルのように CSS のコーディング規約として [BEM](https://getbem.com/) を採用する場合は後者の nested にする必要があります。

nested では、以下のようにクラス名の一部を `&` で補うことができます。例では  `&--primary` の箇所で `&` が `.btn` として補われて `.btn-primary` が定義されます。しかしながら、CSS nesting では対応していません。

```css
@layer components {
  .btn {
    /* 省略 */

    &--primary {
      /* 省略 */
    }
  }
}
```

というわけで今回は CSS nested を使います。参考までに tailwindcss で CSS nesting を使う場合の PostCSS の設定は次に挙げておきます。 `plugins` の指定が配列からオブジェクトになり、 `tailwindcss/nesting` を読み込むときのパラメーターとして 'postcss-nesting' を指定しているのが変更点です。

```javascript
/* 今回はこれは使わない。今後 CSS nesting を使うことがあればこのように設定する。 */
module.exports = {
  plugins: {
    'postcss-import': {},
    'tailwindcss/nesting': 'postcss-nesting',
    tailwindcss: {},
    autoprefixer: {},
  }
}
```

それでは、いくつかの CSS ファイルを CSS nested な記述に変えます。

`app/assets/stylesheets/components/btn.css`

```css
@layer components {
  .btn {
    @apply
      inline-block
      py-1.5 px-4
      rounded-md
      bg-origin-border
      bg-transparent
      border-solid border-2 border-transparent
      font-bold
      no-underline
      cursor-pointer
      outline-none
      [transition:filter_400ms,color_200ms]
      hover:[transition:filter_250ms,color_200ms]
      focus:[transition:filter_250ms,color_200ms]
      focus-within:[transition:filter_250ms,color_200ms]
      active:[transition:filter_250ms,color_200ms];

    &--primary {
      @apply text-white bg-gradient-to-r from-primary to-primary-rotate
        hover:text-white hover:saturate-[1.4] hover:brightness-[115%]
        focus:text-white focus:saturate-[1.4] focus:brightness-[115%]
        focus-within:text-white focus-within:saturate-[1.4] focus-within:brightness-[115%]
        active:text-white active:saturate-[1.4] active:brightness-[115%];
    }

    &--secondary {
      @apply text-white bg-gradient-to-r from-secondary to-secondary-rotate
        hover:text-white hover:saturate-[1.2] hover:brightness-[110%]
        focus:text-white focus:saturate-[1.2] focus:brightness-[110%]
        focus-within:text-white focus-within:saturate-[1.2] focus-within:brightness-[110%]
        active:text-white active:saturate-[1.2] active:brightness-[110%];
    }

    &--light {
      @apply text-dark bg-light
        hover:text-dark hover:brightness-[92%]
        focus:text-dark focus:brightness-[92%]
        focus-within:text-dark focus-within:brightness-[92%]
        active:text-dark active:brightness-[92%];
    }

    &--dark {
      @apply text-white border-dark bg-dark
        hover:text-white
        focus:text-white
        focus-within:text-white
        active:text-white;
    }
  }
}
```

`app/assets/stylesheets/components/quote.css`

```css
@layer components {
  .quote {
    @apply flex justify-between text-center items-center gap-3 bg-white rounded-md shadow-sm mb-4 p-2
      md:py-2 md:px-4;

    &__actions {
      @apply flex flex-[0_0_auto] gap-2 self-start;
    }
  }
}
```

`app/assets/stylesheets/components/form.css`

```css
@layer components {
  .form {
    @apply flex flex-wrap gap-2;

    &__group {
      @apply flex-1;
    }

    &__input {
      @apply block w-full max-w-full py-1.5 px-2 border-solid border-2 border-light rounded-md outline-none
        transition-shadow duration-200
        focus:[box-shadow:0_0_0_2px_theme(colors.glint)];

      &--invalid {
        @apply border-primary;
      }
    }
  }
}
```

ここまで。
ブラウザで見た目がまったく同じであることを確認。

前回の作業中に tailwindcss では @import と CSS nested が使えないことを発覚したため、かなり焦っていました。でも、これで CSS ファイル群がチュートリアルと同じディレクトリ構成・内容にできました。なんとかなってよかったです。

今回はここまで。

ソースコードは [takaokouji/quote-editor](https://github.com/takaokouji/quote-editor) においていますので、興味がある方は Watch していただけると励みになります。

### 協力者の募集

[スモウルビー](https://smalruby.app) ([GitHub](https://github.com/smalruby/smalruby3-develop)) の開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。[スポンサーも募集しています](https://github.com/sponsors/smalruby)。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
