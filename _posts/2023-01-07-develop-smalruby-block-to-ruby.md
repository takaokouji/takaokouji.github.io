---
layout: single
title: "スモウルビーの開発方法:スモウルビーのブロックをRubyのプログラムに変換する"
header:
  overlay_image: /assets/images/develop-smalruby-block-to-ruby/overlay.png
  overlay_filter: 0.4
  caption: "ブロックをRubyのコードに変換する"
categories: output
tags: smalruby
toc: true
last_modified_at: 2023-01-07T11:11:07:09+0900
---

[先日の続き](/output/develop-smalruby-ruby-to-block/) です。今回はスモウルビーそのものを改良して、スモウルビーのブロックをRubyのプログラムに変換するやり方を説明します。

{% include advertisements.html %}

### やりたいこと: スモウルビーのブロックをRubyのプログラムに変換する

イベントブロック `フラグが押されたとき` を Ruby のプログラム `when_flag_clicked do ~ end` に変換できるようにします。

![ブロックをRubyのプログラムに変換する](/assets/images/develop-smalruby-block-to-ruby/overlay.png)

例によって最終的な修正内容をざっと見てください。これでだいたい何をするのか、わかると思います。

- [feat: when\_flag\_cliecked \#326](https://github.com/smalruby/smalruby3-gui/pull/326/files)

今回もチュートリアル形式で説明していきます。

スモウルビーのブロックをRubyのプログラムに変換する処理は、ブロックのカテゴリごとにファイルを分けて実装しています。今回は、イベントカテゴリなので修正するのは次のファイルです。

- テスト
  - [smalruby3\-gui/test/integration/ruby\-tab/events\.test\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/test/integration/ruby-tab/events.test.js)
- 実装
  - [smalruby3\-gui/src/lib/ruby\-generator/event\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/src/lib/ruby-generator/event.js)

### 準備

まずは常にテストを実行できる状態にします。[smalruby3-develop](https://github.com/smalruby/smalruby3-develop)レポジトリを利用して、Docker上で開発しているので、docker-composeコマンドを使います。

```shell
docker-compose run --rm gui bash -c "\$(npm bin)/jest --watch"
```

しばらくすると以下のように表示されるはずです。

```
No tests found related to files changed since last commit.
Press `a` to run all tests, or run Jest with `--watchAll`.

Watch Usage
 › Press a to run all tests.
 › Press p to filter by a filename regex pattern.
 › Press t to filter by a test name regex pattern.
 › Press q to quit watch mode.
 › Press Enter to trigger a test run.
```

さらに、今回はテストの実行前に、修正したJavaScriptをコンパイルして1つのファイルにする必要があります。

なんだか難しそうな気がしますが大丈夫です。テストと同じように、ファイルを保存したタイミングで自動的にコンパイルしてくれる仕組みが用意されています。そのため以下のコマンドを実行すればOKです。

```shell
docker-compose run --rm gui npm run watch
```

これにはかなり時間がかかりますが、以下のように表示されたら準備完了です。OK的な表示がでないので不安になりますが、NGの場合は赤色の字でいろいろ出るので、エラーが発生したことがわかると思います。

```
    Child worker:
         2 assets
        Entrypoint main = extension-worker.js extension-worker.js.map
           20 modules
```

### テストの実装

つぎにテストを作ります。

[smalruby3-gui/test/integration/ruby-tab/events.test.js:32行目](https://github.com/smalruby/smalruby3-gui/blob/646f28b28c9cfa3434413d010670099ffe5b0dfc/test/integration/ruby-tab/events.test.js#L32) に記述されている変換後のRubyのプログラムを修正します。

```ruby
# 修正前
self.when(:flag_clicked) do
end

# 修正後
when_flag_clicked do
end
```

テストの修正はこれだけです。簡単ですね。

保存すると自動的にテストが実行されて、以下のようなエラーが表示されます。これでOKです。それにしても、jestの実行結果はわかりやすい。

```
    Difference:

    - Expected
    + Received

    @@ -1,6 +1,6 @@
    - when_flag_clicked do
    + self.when(:flag_clicked) do
```

### 変換処理の実装

つぎに変換処理を実装します。

[smalruby3-gui/src/lib/ruby-generator/event.js:7行目](https://github.com/smalruby/smalruby3-gui/blob/646f28b28c9cfa3434413d010670099ffe5b0dfc/src/lib/ruby-generator/event.js#L7) を修正します。

```javascript
Generator.event_whenflagclicked = function (block) { // (1)
    block.isStatement = true; // (2)
    return `${Generator.spriteName()}.when(:flag_clicked) do\n`; // (3)
};
```
変換処理では、次のようことを行います。

- `Generator.%ブロック名%` に変換を行う関数をセットします (1)。先日と同じように今回の変換対象のブロック名は `event_whenflagclicked` ですので、 `Generator.event_whenflagclicked` となります。
- 変換後のRubyのプログラムが式であれば、isStatement を true にします (2)。x座標のような変数の場合は isStatement に対して何もせず、デフォルトの false のままにします。

- 最後に変換後のRubyのプログラムを生成して、関数の戻り値として返します(3)。また、 `(10)歩動かす` のようにブロックに引数がある場合は、ここで引数を取り出して Ruby のプログラムに変換します [smalruby3-gui/src/lib/ruby-generator/motion.js:8行目](https://github.com/smalruby/smalruby3-gui/blob/646f28b28c9cfa3434413d010670099ffe5b0dfc/src/lib/ruby-generator/motion.js#L8) 。

今回は最後のRubyのプログラムを変更するだけです。

```javascript
Generator.event_whenflagclicked = function (block) {
    block.isStatement = true;
    return `when_flag_clicked do\n`; // ここを修正
};
```

保存すると、テストが自動的に実行されて、関連するすべてのテストがパスすれば完成です。

```
(省略)
Test Suites: 3 passed, 3 total
Tests:       17 passed, 17 total
Snapshots:   0 total
Time:        43.538s
```

修正ができたら、コミットしてpushします。そして、PRを作成して私がレビューしてマージです。

これで、イベントブロック `フラグが押されたとき` を Ruby のプログラム `when_flag_clicked do ~ end` に変換できるようになりました。今回はとても簡単でしたね(※)。

### まとめ

まとめます。

スモウルビーのブロックをRubyのプログラムに変換する処理は、

- `jest --watch` と `npm run watch` を実行してテストを実行する準備をする
- [smalruby3\-gui/test/integration/ruby\-tab/](https://github.com/smalruby/smalruby3-gui/blob/develop/test/integration/ruby-tab/) にテストを実装する
- [smalruby3\-gui/src/lib/ruby\-generator/](https://github.com/smalruby/smalruby3-gui/blob/develop/src/lib/ruby-generator/) に変換処理を実装する
- コミットしてpush、PRを作成する
- Circle CIが通ればマージする

という流れで実装します。その逆である [Rubyのプログラムをスモウルビーのブロックに変換すること](/output/develop-smalruby-ruby-to-block/) と比べると簡単にできましたね。

### 協力者の募集

スモウルビーの開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。

- - -

※ 変換処理を作ることは簡単でしたが、その前段階として、手元で自動テストを正しく動作させることが大変でした。 [Docker上でjest + Selenium + Headless ChromeでE2Eテストを実現する](/output/docker-jest-e2e-test/) 、 [test: add test for event blocks to generate ruby \#324](https://github.com/smalruby/smalruby3-gui/pull/324/files) 、 [test: block to ruby \#325](https://github.com/smalruby/smalruby3-gui/pull/325/files) がその足跡です。
