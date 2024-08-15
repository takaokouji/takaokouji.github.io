---
layout: single
title: “package-lock.json、原因はおまえかあああああッ！！！”
categories: output
tags: smalruby
toc: true
last_modified_at: 2024-08-16T00:00:00:00+0900
---

[ここしばらく smalruby3-gui に scratch-gui の修正内容を取り込もうと四苦八苦していました](/output/smalruby3-gui-merge-upstream-in-2024-08-13/) が、ついに終えることができました！

原因は package-lock.json でした。

---

私が開発している [smalruby3-gui](https://github.com/smalruby/smalruby3-gui) は、Scratch Foundationが開発している [scratch-gui](https://scratchfoundation/scratch-gui) をベースにして、Scratch のブロックとRuby スクリプトを相互変換できる機能を追加しています。オープンソースソフトウェアなので、誰でも自由に開発や再配布ができます。

定期的に最新の変更内容を upstream から取り込んでいます。基本的な手順は [こちら](https://github.com/smalruby/smalruby3-gui/wiki/merge_scratch-gui_develop)にまとめています。

今回もそれに従って進めていたのですが、エラーの対応に手間取っていました。

scratch-gui は期待通りに動作することを確認していたので、 smalruby3-gui との差分を一つ一つ地道に revert して失くしていったのですが、それでもエラーが発生します。
src 以下のアプリケーションコードをすべて revert したので、次は Webpack の設定、 package.json と進めたのですが、それでもエラーが発生する。

で、もしやと思って、 package-lock.json を revert してから npm install したところ、エラーが解消されました！

おそらく scratch-vm を update した際に関係のないライブラリのバージョンを上げてしまったみたいです。細かいところまでは追っていませんが、ようやく最新の scratch-gui の修正内容を smalruby3-gui に取り込むことができました。

<https://github.com/smalruby/smalruby3-gui/commit/b5d548e72203cd3756365b38db8e7ab538e85328>

その後も、 GitHub Actions の設定変更などを経て、無事、マージ・リリースすることができました。イェイ！

ただ、見た目は何も変わっていないので、苦労の割にうれしさは少ないのが少し残念です。

### 協力者の募集

スモウルビーの開発にご協力いただける方を常に募集しています。

ご協力いただける方は、 contact@smalruby.jp までご連絡いただいてもいいですし、連絡なしで「xxx のブロックに対応しました」というPRを作成してもらってもかまいません。むしろその方が好都合です。

また、 [拙著:小学生から楽しむ きらきらRubyプログラミング](https://amzn.to/3SLNXrk) をご購入いただけるとありがたいです。スモウルビーの使い方と教え方を学ぶことができる書籍です。特に小・中学校の先生に読んでいただきたいです。
<img src="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg" srcset="https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL320_.jpg 1x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL480_FMwebp_QL65_.jpg 1.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL640_FMwebp_QL65_.jpg 2x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL800_FMwebp_QL65_.jpg 2.5x, https://m.media-amazon.com/images/I/91Vcir5bhiL._AC_UL960_FMwebp_QL65_.jpg 3x" alt="小学生から楽しむ きらきらRubyプログラミング">

日本中の小・中学生が学校の授業や地域のプログラミング教室でスモウルビーを使っています。みなさんのご協力で、たくさんの子どもたちがハッピーになります。ご協力、よろしくお願いします。
