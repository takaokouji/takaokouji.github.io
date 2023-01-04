---
layout: single
title: "スモウルビーの開発方法:Rubyのプログラムをスモウルビーのブロックに変換する"
header:
  overlay_image: /assets/images/develop-smalruby-ruby-to-block/overlay.png
  overlay_filter: 0.4
  caption: "Rubyのコードをブロックに変換する"
categories: output
tags: smalruby
toc: false
last_modified_at: 2023-01-04T16:16:58:44+0900
---

今回はスモウルビーそのものを改良するときのやり方を説明します。開発するのは、Rubyのプログラムをスモウルビーのブロックに変換する機能です。

{% include advertisements.html %}

半年ぶりのスモウルビーの開発は難しかった...。

やりたいことは、MADR「 [self\.whenからself\.を取り除いたRubyの命令を検討する](https://github.com/smalruby/smalruby3-gui/blob/develop/docs/adr/0001-stop-sprite-when-method.ja.md) 」で決めた、イベントブロックと `when_%event_type%(%args%)` との相互変換です。

しかし、

- なにから手を付けたらいいんだっけ？
- テストはどうやっていたんだっけ？
- 動作確認はどうするんだっけ？

と、疑問だらけ。

少しずつ思い出しながら進めていますが、近い将来の自分のために、開発のためのドキュメントを残しておこうと思います。

### やりたいこと: Rubyのプログラムをスモウルビーのブロックに変換する

なにはともあれ最終的な修正内容をざっと見てください。これでだいたい何をするのか、わかると思います。

- [feat: when_flag_clicked / ruby to block [#309] #321](https://github.com/smalruby/smalruby3-gui/pull/321/files)

それでは、チュートリアル形式でスモウルビーそのものの開発方法を説明していきます。

Rubyのプログラムをスモウルビーのブロックに変換する処理は、ブロックのカテゴリごとにファイルを分けて実装しています。今回は、イベントカテゴリなので修正するのは次のファイルです。

- テスト
  - [smalruby3\-gui/test/unit/lib/ruby\-to\-blocks\-converter/event\.test\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/test/unit/lib/ruby-to-blocks-converter/event.test.js)
- 実装
  - [smalruby3\-gui/src/lib/ruby\-to\-blocks\-converter/event\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/src/lib/ruby-to-blocks-converter/event.js)

他のカテゴリもファイル名からどのファイルに実装されているのか推測できると思います。基本的なブロックだけでなく、拡張機能のものも同じところにあります。

今回は、Ruby の命令 `when_flag_clicked do ~ end` を、イベントブロック `フラグが押されたとき` に変換できるようにします。

まずは常にテストを実行できる状態にします ([smalruby3-develop](https://github.com/smalruby/smalruby3-develop)レポジトリを利用して、Dockerを使って開発しています) 。

```shell
docker-compose run --rm gui bash -c "\$(npm bin)/jest --watch"
```

しばらくして以下のように表示されたら準備完了です。

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

つぎにテストを作ります。先に変換処理を実装してもいいのですが、動作確認でブラウザを操作するのが手間なのと、テストを後で実装するとなると面倒くさくなります。私は先にテストから書くことをオススメします。

[smalruby3\-gui/test/unit/lib/ruby\-to\-blocks\-converter/event\.test\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/test/unit/lib/ruby-to-blocks-converter/event.test.js) を修正します。

以下が今回の修正対象のテストです。テストは [jest](https://jestjs.io/ja/) を使っています。

```javascript
    describe('event_whenflagclicked', () => {
        test('normal', () => {
```

修正前は以下のようになっていました。

```javascript
code = 'self.when(:flag_clicked) { bounce_if_on_edge }'; // (1)
expected = [ // (2)
    {
        opcode: 'event_whenflagclicked',
        next: {
            opcode: 'motion_ifonedgebounce'
        }
    }
];
convertAndExpectToEqualBlocks(converter, target, code, expected); // (3)
```

- (1) 変換対象のRubyのプログラムを code 変数に代入する
- (2) 変換結果のスモウルビーのブロック (を表現したデータ) を expected 変数に代入する
- (3) 実際にチェックする
  - convertAndExpectToEqualBlocks がうまいことやってくれる

単純に修正するだけならテストは以下のように修正すればOKです。

```javascript
code = 'when_flag_clicked { bounce_if_on_edge }' // 修正したのはここだけ
expected = [
    {
        opcode: 'event_whenflagclicked',
        next: {
            opcode: 'motion_ifonedgebounce'
        }
    }
];
convertAndExpectToEqualBlocks(converter, target, code, expected);
```

実際には、 `self.when` もこれまでと同じように変換できることを確認しておきたいため、以下のように修正しました。ついでに、いくつかのパターンも追加しています。

```javascript
expected = [
    {
        opcode: 'event_whenflagclicked',
        next: {
            opcode: 'motion_ifonedgebounce'
        }
    }
];
[
    'self.when(:flag_clicked) { bounce_if_on_edge }',
    'when_flag_clicked { bounce_if_on_edge }',
    'when_flag_clicked() { bounce_if_on_edge }', // ()を省略しない場合
    'self.when_flag_clicked { bounce_if_on_edge }' // self.を省略しない場合
].forEach(s => {
    convertAndExpectToEqualBlocks(converter, target, s, expected);
});
```

これを保存すると、自動的にテストが実行されて以下のようなエラーになります。実際には色付けされていて、エラーは赤色で表示されるのでわかりやすいです。 [jest](https://jestjs.io/ja/) はとても親切ですね。

```
 FAIL  test/unit/lib/ruby-to-blocks-converter/event.test.js (26.179s)
  ● RubyToBlocksConverter/Event › event_whenflagclicked › normal

    expect(received).toHaveLength(length)

    Expected value to have length:
      0
    Received:
      [{"column": 0, "row": 0, "source": "when_flag_clicked", "text": "\"{SOURCE}\" is the wrong instruction.", "type": "error"}]
    received.length:
      1

      at convertAndExpectToEqualBlocks (test/helpers/expect-to-equal-blocks.js:229:28)
      at test/unit/lib/ruby-to-blocks-converter/event.test.js:38:64
          at Array.forEach (<anonymous>)
      at Object.<anonymous> (test/unit/lib/ruby-to-blocks-converter/event.test.js:37:7)
          at new Promise (<anonymous>)
      at processTicksAndRejections (internal/process/task_queues.js:95:5)
```

つぎに変換処理を実装します。

[smalruby3\-gui/src/lib/ruby\-to\-blocks\-converter/event\.js](https://github.com/smalruby/smalruby3-gui/blob/develop/src/lib/ruby-to-blocks-converter/event.js) を修正します。

今回は「send(メソッド呼び出し)」という種類のRubyの命令を変換するため、 `onSend` を修正します。

```javascript
onSend: function (receiver, name, args, rubyBlockArgs, rubyBlock) {
```

メソッド呼び出しのレシーバーが `self` か、未指定 (スモウルビーでは `Opal.nil`) のどちらかであることをチェックして、

```javascript
} else if (this._isSelf(receiver) || receiver === Opal.nil) {
```

さらに以下のチェックをして、

- メソッド名が `when_flag_clicked` であること
- 引数が指定されていないこと
- ブロック引数が指定されていること
- ブロック変数 (ブロックパラメーター) が指定されていないこと

```javascript
switch (name) {
// 省略
case 'when_flag_clicked':
    if (args.length == 0 && rubyBlockArgs && rubyBlockArgs.length === 0 && rubyBlock) {
```

ようやくブロックを作る処理です。ブロック名 `event_whenflagclicked` とブロックの形状 `hat` を指定します。

```javascript
block = this._createBlock('event_whenflagclicked', 'hat');
```

さらに、作ったブロックの中にRubyのブロック引数で指定した処理を入れるために、それを Ruby からブロックに変換したもの (rubyBlock) との親子関係を指定します。

```javascript
this._setParent(rubyBlock, block);
```

これで変換処理ができました。

保存すると、テストが自動的に実行されて、以下のような結果が表示されるはずです。

```
 PASS  test/unit/lib/ruby-to-blocks-converter/event.test.js
  RubyToBlocksConverter/Event
    event_whenflagclicked
      ✓ normal (71ms)
      ✓ hat (26ms)
      ✓ invalid (24ms)
      ✓ error (10ms)
(省略)
Test Suites: 1 passed, 1 total
Tests:       34 passed, 34 total
Snapshots:   0 total
Time:        6.602s
```

スモウルビーのベースとしている [Scratch](https://scratch.mit.edu) の [scratch-gui](https://github.com/LLK/scratch-gui) にはプログラミング言語からの変換処理はありません。そのため、独自に開発する必要がありました。仕組みを考えて、実際に動くようにするまでは大変でしたが、こうしてみるとよくできていますね。

なお、 `event_whenflagclicked` のようにRubyの命令に対応するスモウルビーのブロックの名前を知っていないといけないのですが、それらは [scratch-blocks](https://github.com/LLK/scratch-blocks) の [scratch-blocks/blocks_vertical/](https://github.com/LLK/scratch-blocks/tree/develop/blocks_vertical) に記述されています。

今回のものは [scratch\-blocks/blocks\_vertical/event\.js:73行目](https://github.com/LLK/scratch-blocks/blob/7575c9a0f2c267676569c4b102b76d77f35d9fd6/blocks_vertical/event.js#L73) に記述されています。

```javascript
Blockly.Blocks['event_whenflagclicked'] = {
  /**
   * Block for when flag clicked.
   * @this Blockly.Block
   */
  init: function() {
    this.jsonInit({
      "id": "event_whenflagclicked", // ブロックの名前
      "message0": Blockly.Msg.EVENT_WHENFLAGCLICKED,
      "args0": [
        {
          "type": "field_image",
          "src": Blockly.mainWorkspace.options.pathToMedia + "green-flag.svg",
          "width": 24,
          "height": 24,
          "alt": "flag"
        }
      ],
      "category": Blockly.Categories.event,
      "extensions": ["colours_event", "shape_hat"] // ブロックの形状は hat
    });
  }
};
```

これらのファイルには開発で使う様々な情報が記述されています。例えば、イベントブロック `[スペース▼]キーが押されたとき` は、以下のように記述されていて、 `[スペース▼]` の名前が `KEY_OPTION` であるということがわかります。

[scratch\-blocks/blocks\_vertical/event\.js:265行目](https://github.com/LLK/scratch-blocks/blob/7575c9a0f2c267676569c4b102b76d77f35d9fd6/blocks_vertical/event.js#L265)
```javascript
Blockly.Blocks['event_whenkeypressed'] = {
  /**
   * Block to send a broadcast.
   * @this Blockly.Block
   */
  init: function() {
    this.jsonInit({
      "id": "event_whenkeypressed",
      "message0": Blockly.Msg.EVENT_WHENKEYPRESSED,
      "args0": [
        {
          "type": "field_dropdown",
          "name": "KEY_OPTION",  // [スペース▼]の名前
          "options": [
            [Blockly.Msg.EVENT_WHENKEYPRESSED_SPACE, 'space'],
            // 省略
            ['9', '9']
          ]
        }
      ],
      "category": Blockly.Categories.event,
      "extensions": ["colours_event", "shape_hat"]
    });
  }
};
```

また、 `hat` のようなブロックの形状には次のものがあります。

- statement: `(10) 歩動かす` のように上下にブロックをつけられるもの
- hat: `フラグを押されたとき` のように下にのみブロックをつけられるもの
- terminate: `[すべてを止める▼]` のように上にのみブロックをつけられるもの
- value: `x座標` のような値を表すもの
- value_boolean: `(マウスポインター▼)に触れた` のような、はい/いいえの真偽値を表すもの
  - [一部バグ](https://github.com/smalruby/smalruby3-gui/blob/cca2bafa68572b024dd13b8f0a224a6a1104f918/src/lib/ruby-to-blocks-converter/boost.js#L90) で `boolean` を指定しているものがありますが、正しくはvalue_booleanです。

修正ができたら、コミットしてpushします。コミットメッセージは [commitlint](https://github.com/conventional-changelog/commitlint) に従うようにします。手元で npm install してあれば husky 経由で手元でコミットするときにチェックしてくれるので安心です。

あとはPRを作成してレビューしてマージです。このとき [Circle CIによる自動テスト](https://app.circleci.com/pipelines/github/smalruby) がパスすることもチェックしてくださいね。

これでRubyのプログラム `when_flag_clicked do ~ end` をスモウルビーのブロック `フラグが押されたとき` に変換することができるようになりました。

- - -

まとめます。

Rubyのプログラムをスモウルビーのブロックに変換する処理は、

- `jest --watch` を実行してテストを実行する準備をする
- [smalruby3\-gui/test/unit/lib/ruby\-to\-blocks\-converter/](https://github.com/smalruby/smalruby3-gui/blob/develop/test/unit/lib/ruby-to-blocks-converter/) にテストを実装する
- [smalruby3\-gui/src/lib/ruby\-to\-blocks\-converter/](https://github.com/smalruby/smalruby3-gui/blob/develop/src/lib/ruby-to-blocks-converter/) に変換処理を実装する
- コミットしてpush、PRを作成する
- Circle CIが通ればマージする

という流れで実装します。

### 協力者の募集

スモウルビーの拡張機能のブロックは、Rubyのプログラムからスモウルビーのブロックに変換できないものがあります。理由は私の作業時間が取れないからです。そのため、スモウルビーにご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
