---
layout: single
title: スモウルビーのOpalを1.5.1にアップデートしました！
categories: output
tags: smalruby
toc: false
last_modified_at: 2023-01-03T12:12:54:03+0900
---

スモウルビーのOpalを1.5.1にアップデートしました。たまにしかアップデートしないため、ここに記録を残しておきます。ついでにスモウルビーでどのようにOpalを利用しているのかも説明します。

{% include advertisements.html %}

スモウルビーでは、Rubyのプログラムからスモウルビーのブロックへ変換するときに [Opal](https://opalrb.com/) を利用しています。

[Opal](https://opalrb.com/) は、Ruby のプログラムを JavaScript のプログラムに変換するためのソフトウェアです。このようにある言語から別の言語に変換するためのソフトウェアのことをトランスパイラと呼びます。

[Parser](https://github.com/whitequark/parser) という Ruby のプログラムを解析してプログラムで扱いやすいデータ (構文木) にすることができる Ruby のライブラリがあります。これを [Opal](https://opalrb.com/) を利用して Ruby から JavaScript に変換して JavaScript で記述されたスモウルビーで利用しています。

スモウルビーのソースコードでいうと、 [smalruby3\-gui/opal/](https://github.com/smalruby/smalruby3-gui/tree/develop/opal) に、 Opal 本体 と、Parser を JavaScript に変換したものを含んでいる [opal-parser](https://github.com/opal/opal/blob/master/docs/opal_parser.md) を配置しています。確認してみると、Opalのバージョンは 0.11.4 でした。 0.11.4 がリリースされたのは Nov 7, 2018 とのことなのでもう4年以上前になりますね。

そして、[smalruby3\-gui/opal/config\-opal\-parser\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/opal/config-opal-parser.js) で読み込んでいます。パーザーが対象としている Ruby のバージョンは 2.3 です。実は、2.3にしたいのではなくて、利用している opal-parser に同梱されているのが 2.3 だけだったので仕方なくそうしています。

```javascript
Opal.load('opal-parser');
Opal.load('parser');
Opal.load('parser/ruby23');
Opal.Parser.CurrentRuby = Opal.Parser.Ruby23;
```

これらは [smalruby3\-gui/scripts/make\-setup\-opal\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/scripts/make-setup-opal.js) によって、ビルドするときに連結されて、 setup-opal.js という1つのファイルになってブラウザに読み込まれます。

実際にParserのparseメソッドを呼び出しているのは、
[smalruby3-gui/src/lib/ruby-to-blocks-converter/index.js](https://github.com/smalruby/smalruby3-gui/blob/4572089e542b18e2b857eb4dd61c166876a5e95d/src/lib/ruby-to-blocks-converter/index.js#L160)
です。

```javascript
const root = RubyParser.$parse(code);
```

Parserのparseメソッドの前に `$` がついています。Opal では JavaScript から Ruby で定義されたメソッドを呼び出すときには `$` をつけることになっています。これはJavaScriptのメソッドと区別するためですね。

また、RubyParserはスモウルビーで定義したオブジェクトです。Parserのままでは使いにくいところが少しあったので、スモウルビーの起動時に Ruby で記述したモンキーパッチを Parser に適用しています。随分前に実装したところなのですが、我ながらすごいことをしていますね。

[smalruby3\-gui/src/lib/ruby\-parser\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/src/lib/ruby-parser.js)
```javascript
const patch = Opal.String.$new(`
# (省略)
module Parser
  class Diagnostic
    def render_line(range, ellipsis=false, range_end=false)
      source_line    = range.source_line
# (省略)
    end
  end
end
`);
eval(Opal.Opal.$compile(patch)); // eslint-disable-line no-eval

export default Opal.Parser.CurrentRuby;
```

このようにして、スモウルビーでは Opal を使って Ruby のプログラムを解析してブロックに変換しています。

しかし、まだ続きがあって、スモウルビーの単体テストは Node.js で実行しているのですが、残念ながらブラウザ用の Opal は使えませんでした。そこで単体テストでは Node.js 用に改良されたものを使っています。

- [Opal Runtime for Node\.js](https://github.com/mogztter/opal-node-runtime): 1.0.14
- [Opal Compiler for Node\.js](https://github.com/mogztter/opal-node-compiler): 1.0.15

これらに対応する Opal は 1.0.0 で、opal-compilerに含まれるパーザーは Ruby 2.5用のものです。つまり、ブラウザと単体テストで Opal とパーザーのバージョンが異なっています。これは良くないことなのですが、当時から今に至るまで解決方法を見つけられていません。

それで、思い立ってバージョンを揃えてみようと思って、まずは Node.js 用のものを最新のものにアップデートしてみました。

```diff
diff --git a/package.json b/package.json
index 85186dc33..b2b5df0e0 100644
--- a/package.json
+++ b/package.json
@@ -60,8 +60,8 @@
     "lodash.throttle": "4.0.1",
     "minilog": "3.1.0",
     "omggif": "1.0.9",
-    "opal-compiler": "^1.0.15",
-    "opal-runtime": "^1.0.14",
+    "opal-compiler": "^2.2.0",
+    "opal-runtime": "^2.4.0",
     "papaparse": "5.3.0",
     "postcss-import": "^12.0.0",
     "postcss-loader": "^3.0.0",
```

そして、単体テストを実行すると、

```
$ docker-compose run --rm gui bash -c "\$(npm bin)/jest test/unit/lib/ruby-to-blocks-converter/control.test.js"
Creating smalruby3-develop_gui_run ... done
Object freezing is not supported by Opal
 FAIL  test/unit/lib/ruby-to-blocks-converter/control.test.js
  ● Test suite failed to run

    TypeError: $$(...).$first is not a function

      at Object.<anonymous>.Opal.modules.nodejs/base (node_modules/opal-runtime/src/nodejs.js:15:24)
      at Object.<anonymous>.Opal.load (node_modules/opal-runtime/src/opal.js:2661:20)
      at Object.<anonymous>.Opal.require (node_modules/opal-runtime/src/opal.js:2694:17)
      at constructor.$require (node_modules/opal-runtime/src/opal.js:5363:19)
      at Object.<anonymous>.Opal.modules.nodejs (node_modules/opal-runtime/src/nodejs.js:3109:8)
      at Object.<anonymous>.Opal.load (node_modules/opal-runtime/src/opal.js:2661:20)
      at Object.<anonymous>.Opal.require (node_modules/opal-runtime/src/opal.js:2694:17)
      at Object.<anonymous> (node_modules/opal-compiler/src/index.js:5:6)
      at Object.<anonymous> (test/helpers/opal-setup.js:11:1)
          at Generator.next (<anonymous>)
      at processTicksAndRejections (internal/process/task_queues.js:95:5)

Test Suites: 1 failed, 1 total
Tests:       0 total
Snapshots:   0 total
Time:        25.043s
Ran all test suites matching /test\/unit\/lib\/ruby-to-blocks-converter\/control.test.js/i.
ERROR: 1
```

と、こんな具合にエラーがでて、簡単にアップデートできないことがわかりました。残念です。開発に利用している Node.js のバージョンが v14.21.2 なのが問題な気がして、なるべく最新のものに変えてみたりもしましたが、エラー内容は変わりませんでした。

とりあえず、Node.js用のOpalの更新はあきらめて、実行時に使っている [smalruby3\-gui/opal/](https://github.com/smalruby/smalruby3-gui/tree/develop/opal) の各ファイルを更新しました。 [Opal の CDN](https://cdn.opalrb.com/opal/1.5.1/index.html) から以下のファイルをダウンロードして上書きして、少しだけ修正すれば更新できました。

- [//cdn\.opalrb\.com/opal/1\.5\.1/opal\.js](https://cdn.opalrb.com/opal/1.5.1/index.html)
- [//cdn\.opalrb\.com/opal/1\.5\.1/opal\.min\.js](https://cdn.opalrb.com/opal/1.5.1/index.html)
- [//cdn\.opalrb\.com/opal/1\.5\.1/opal\-parser\.js](https://cdn.opalrb.com/opal/1.5.1/index.html)
- [//cdn\.opalrb\.com/opal/1\.5\.1/opal\-parser\.min\.js](https://cdn.opalrb.com/opal/1.5.1/index.html)

```diff
tk2002mac:smalruby3-gui kouji$ git diff opal/config-opal.js opal/config-opal-parser.js
diff --git a/opal/config-opal-parser.js b/opal/config-opal-parser.js
index 931980b04..e2a4a2989 100644
--- a/opal/config-opal-parser.js
+++ b/opal/config-opal-parser.js
@@ -1,4 +1,4 @@
 Opal.load('opal-parser');
 Opal.load('parser');
-Opal.load('parser/ruby23');
-Opal.Parser.CurrentRuby = Opal.Parser.Ruby23;
+Opal.load('parser/ruby31');
+Opal.Parser.CurrentRuby = Opal.Parser.Ruby31;
diff --git a/opal/config-opal.js b/opal/config-opal.js
index 913237fae..fa5d20999 100644
--- a/opal/config-opal.js
+++ b/opal/config-opal.js
@@ -1,2 +1 @@
-Opal.load('opal');
 Opal.config.unsupported_features_severity = 'ignore';
```

ふと思い立って、実行時の Opal をそのまま自動テストでも使えるようにしてみました。すると、きちんと動作するではありませんか。

```diff
diff --git a/package.json b/package.json
index 85186dc33..cadc7713c 100644
--- a/package.json
+++ b/package.json
@@ -60,8 +60,6 @@
     "lodash.throttle": "4.0.1",
     "minilog": "3.1.0",
     "omggif": "1.0.9",
-    "opal-compiler": "^1.0.15",
-    "opal-runtime": "^1.0.14",
     "papaparse": "5.3.0",
     "postcss-import": "^12.0.0",
     "postcss-loader": "^3.0.0",
@@ -153,7 +151,7 @@
     "setupFiles": [
       "raf/polyfill",
       "<rootDir>/test/helpers/enzyme-setup.js",
-      "<rootDir>/test/helpers/opal-setup.js"
+      "<rootDir>/static/javascripts/setup-opal.js"
     ],
     "testPathIgnorePatterns": [
       "src/test.js"
```

おそらく、Node.jsを10から14にバージョンアップさせたことが要因ではないかと思っていますが、詳しくは調べていません。無事に Opal をアップデートすることができました!

opal-runtimeパッケージに合わせて、Opalのバージョンを1.5.1にしたのですが、これなら最新のOpalにバージョンアップすることができそうです。よかった。

- - -

無事、Opalをアップデートすることができました。

今後のためにスモウルビーの Opal についてまとめておきます。

- スモウルビーではRubyからブロックに変換するために Opal を利用している
  - [smalruby3-gui/src/lib/ruby-to-blocks-converter/index.js](https://github.com/smalruby/smalruby3-gui/blob/4572089e542b18e2b857eb4dd61c166876a5e95d/src/lib/ruby-to-blocks-converter/index.js#L160)
- Opalは[smalruby3\-gui/opal/](https://github.com/smalruby/smalruby3-gui/tree/develop/opal)に配置している
- Opalのバージョンは 1.5.1。Rubyのパーザーのバージョンは 3.1。
- Opalのバージョンアップは[Opal の CDN](https://cdn.opalrb.com/opal/1.5.1/index.html) から以下のファイルをダウンロードして上書きすればOK
  - opal.js
  - opal.min.js
  - opal-parser.js
  - opal-parser.min.js
